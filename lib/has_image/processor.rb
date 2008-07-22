require 'rubygems'
require 'mini_magick'

module HasImage
  
  class ProcessorError < StandardError ; end
  
  class Processor
    
    attr_accessor :options

    def initialize(options)
      @options = options
    end
    
    # Arg should be either a file, or a path. This runs ImageMagick's
    # "identify" command and looks for an exit status indicating an error. If
    # there is no error, then ImageMagick has identified the file as something
    # it can work with and it will be converted to the desired output format.
    def self.valid?(arg)
      arg.close if arg.respond_to?(:close) && !arg.closed?
      silence_stderr do
        `identify #{arg.respond_to?(:path) ? arg.path : arg.to_s}`
        $? == 0
      end
    end
    
    # Create the resized image, and transform it to the desired output format,
    # if necessary.
    def resize(my_options)
      silence_stderr do
        my_options[:temp_file].close if !my_options[:temp_file].closed?
        @image = MiniMagick::Image.from_file(my_options[:temp_file].path)
        @image.format(options[:convert_to]) if @image[:format] !=~ /#{options[:convert_to]}/
        @image.combine_options do |commands|
          # Will work on some images, if EXIF data supports it.
          commands.send("auto-orient".to_sym)
          # Remove EXIF data, this can be up to 32k.
          commands.strip
          commands.resize "#{my_options[:size]}^"
          commands.gravity @image[:width] < @image[:height] ? "north" : "center"
          commands.extent "#{my_options[:size]}"
          commands.quality options[:output_quality]
        end
        return @image
      end
    rescue MiniMagick::MiniMagickError
      raise HasImage::ProcessorError.new("That doesn't look like an image file.")
    end
    
  end

end