require 'mini_magick'

module HasImage
  
  # Image processing functionality for the HasImage gem.
  class Processor
    
    attr_accessor :options
    
    class << self
      
      # "The form of an {extended geometry
      # string}[http://www.imagemagick.org/script/command-line-options.php?#resize] is
      # <width>x<height>{+-}<xoffset>{+-}<yoffset>{%}{!}{<}{>}"
      def geometry_string_valid?(string)
        string =~ /\A[\d]*x[\d]*([+-][0-9][+-][0-9])?[%@!<>^]?\Z/
      end
      
      # Arg should be either a file, or a path. This runs ImageMagick's
      # "identify" command and looks for an exit status indicating an error. If
      # there is no error, then ImageMagick has identified the file as something
      # it can work with and it will be converted to the desired output format.
      def valid?(arg)
        arg.close if arg.respond_to?(:close) && !arg.closed?
        silence_stderr do
          `identify #{arg.respond_to?(:path) ? arg.path : arg.to_s}`
          $? == 0
        end
      end
      
    end

    # The constuctor should be invoked with the options set by has_image.
    def initialize(options) # :nodoc:
      @options = options
    end
    
    # Create the resized image, and transforms it to the desired output
    # format if necessary. 
    # 
    # +size+ should be a valid ImageMagick {geometry string}[http://www.imagemagick.org/script/command-line-options.php#resize].
    # +format+ should be an image format supported by ImageMagick, e.g. "PNG", "JPEG"
    # yields the processed Image file as a file-like
    def process(file, size=options[:resize_to], format=options[:convert_to])
      unless size.blank? || Processor.geometry_string_valid?(size)
        raise InvalidGeometryError.new('"%s" is not a valid ImageMagick geometry string' % size)
      end
      with_image(file) do |image|
        convert_image(image, format) if format
        resize_image(image, size) if size
        yield IO.read(image.path) if block_given?
        image
      end
    end
    alias_method :resize, :process #Backwards-compat
    
    # Gets the given +dimension+ (width/height) from the image file at +path+
    def measure(path, dimension)
      MiniMagick::Image.from_file(path)[dimension.to_sym]
    end
    
  private
    # operate on the image with MiniMagick
    # yields a MiniMagick::Image object
    def with_image(file)
      path = file.respond_to?(:path) ? file.path : file
      file.close if file.respond_to?(:close) && !file.closed?
      silence_stderr do
        begin
          image = MiniMagick::Image.from_file(path)
          yield image
        rescue MiniMagick::MiniMagickError
          raise ProcessorError.new("#{path} doesn't look like an image file.")
        ensure
          image.tempfile.close! if defined?(image) && image
        end
      end
    end
  
    # +image+ should be a MiniMagick::Image and +size+ a Geometry String
    # Image resizing is placed in a separate method for easy monkey-patching.
    # This is intended to be invoked from resize, rather than directly.
    # By default, the following ImageMagick functionality is invoked:
    # * auto-orient[http://www.imagemagick.org/script/command-line-options.php#auto-orient]
    # * strip[http://www.imagemagick.org/script/command-line-options.php#strip]
    # * resize[http://www.imagemagick.org/script/command-line-options.php#resize]
    # * gravity[http://www.imagemagick.org/script/command-line-options.php#gravity]
    # * extent[http://www.imagemagick.org/script/command-line-options.php#extent]
    # * quality[http://www.imagemagick.org/script/command-line-options.php#quality]
    def resize_image(image, size)
      image.combine_options do |commands|
        commands.send("auto-orient".to_sym)
        commands.strip
        # Fixed-dimension images
        if size =~ /\A[\d]*x[\d]*!?\Z/
          commands.resize "#{size}^"
          commands.gravity "center"
          commands.extent size
        # Non-fixed-dimension images
        else
          commands.resize "#{size}"
        end
        commands.quality options[:output_quality]
      end
    end

    def convert_image(image, format=options[:convert_to])
      image.format(format) unless image[:format] == format
    end
    
  end

end