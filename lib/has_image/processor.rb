require 'mini_magick'

module HasImage
  
  # Image processing functionality for the HasImage gem.
  class Processor
    
    attr_accessor :options
    
    class << self
      
      # Given a geometry string, return the maxium possible output dimensions.
      # For example:
      #   area("50x50>") == 2500 
      def area(dimensions)
        dimensions.split("x")[0].to_i * dimensions.split("x")[1].to_i 
      end

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
    # format if necessary. The size should be a valid ImageMagick {geometry
    # string}[http://www.imagemagick.org/script/command-line-options.php#resize].
    def resize(file, size)
      raise InvalidGeometryError.new unless Processor.geometry_string_valid?(size)
      silence_stderr do
        path = file.respond_to?(:path) ? file.path : file
        file.close if file.respond_to?(:close) && !file.closed?
        @image = MiniMagick::Image.from_file(path)
        convert_image
        resize_image(size)   
        return @image
      end
    rescue MiniMagick::MiniMagickError
      raise ProcessorError.new("That doesn't look like an image file.")
    end
    
    # Image resizing is placed in a separate method for easy monkey-patching.
    # This is intended to be invoked from resize, rather than directly.
    # By default, the following ImageMagick functionality is invoked:
    # * auto-orient[http://www.imagemagick.org/script/command-line-options.php#auto-orient]
    # * strip[http://www.imagemagick.org/script/command-line-options.php#strip]
    # * resize[http://www.imagemagick.org/script/command-line-options.php#resize]
    # * gravity[http://www.imagemagick.org/script/command-line-options.php#gravity]
    # * extent[http://www.imagemagick.org/script/command-line-options.php#extent]
    # * quality[http://www.imagemagick.org/script/command-line-options.php#quality]
    def resize_image(size)
      @image.combine_options do |commands|
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

    private
    
    # This was placed in a separate method largely to facilitate debugging
    # and profiling.
    def convert_image
      return if @image[:format] == options[:convert_to]
      @image.format(options[:convert_to])
    end
    
  end

end