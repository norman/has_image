module HasImage
  
  class Processor
    
    attr_accessor :storage
    
    def create_thumbnail(size)
      require 'mini_magick'
      @storage.temp_file.close if !@storage.temp_file.closed?
      @image = MiniMagick::Image.from_file(@storage.temp_file.path)
      @image.combine_options do |commands|
        # Remove EXIF data, this can be up to 32k.
        commands.strip
        commands.resize "#{size}^"
        commands.gravity @image[:width] < @image[:height] ? "north" : "center"
        commands.extent "#{size}"
        commands.quality "85"
        # Will work on some images, if EXIF data supports it.
        commands.send(:"auto-orient")
      end
      @image.write("/tmp/test.jpg")
    end
    
  end

end