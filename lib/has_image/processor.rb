# require 'rubygems'
require 'mini_magick'

module HasImage
  
  class ProcessorError < StandardError ; end
  
  class Processor
    
    attr_accessor :options
    
    class << self
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

    def initialize(options)
      @options = options
    end
    
    # Create the resized image, and transform it to the desired output format,
    # if necessary.
    def resize(file, size)
      silence_stderr do
        path = file.respond_to?(:path) ? file.path : file
        file.close if file.respond_to?(:close) && !file.closed?
        @image = MiniMagick::Image.from_file(path)
        convert_image        
        @image.combine_options do |commands|
          commands.send("auto-orient".to_sym)
          commands.strip
          commands.resize "#{size}^"
          commands.gravity "center"
          commands.extent size
          commands.quality options[:output_quality]
        end
        return @image
      end
    rescue MiniMagick::MiniMagickError
      raise ProcessorError.new("That doesn't look like an image file.")
    end
    
    private
    
    def convert_image
      return if @image[:format] == options[:convert_to]
      @image.format(options[:convert_to])
    end
    
  end

end