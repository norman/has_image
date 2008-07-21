require 'mini_magick'
module HasImage
  
  class Processor
    
    attr_accessor :options
    
    def initialize(options)
      @options = options
    end
    
    def resize(my_options)
      my_options[:temp_file].close if !my_options[:temp_file].closed?
      @image = MiniMagick::Image.from_file(my_options[:temp_file].path)
      @image.combine_options do |commands|
        # Remove EXIF data, this can be up to 32k.
        commands.strip
        commands.resize "#{my_options[:size]}^"
        commands.gravity @image[:width] < @image[:height] ? "north" : "center"
        commands.extent "#{my_options[:size]}"
        commands.quality "85"
        # Will work on some images, if EXIF data supports it.
        commands.send(:"auto-orient")
      end
      return @image
    end
    
  end

end