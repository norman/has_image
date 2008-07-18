
module HasImage
  
  class Processor
    
    attr_accessor :storage
    
    def create_thumbnail(size)
      require 'mini_magick'
      copy_temp_from_storage
      @image = MiniMagick::Image.from_file(@temp_file)
      @image.combine_options do |commands|
        # Remove EXIF data, this can be up to 32k.
        commands.strip unless attachment_options[:keep_profile]
        commands.size "#{size}"
        commands.thumbnail "#{size}^"
        commands.gravity @image.width < @image.height ? "north" : "center"
        commands.crop "#{size}+0+0"
        commands.quality "85"
        # Will work on some images, if EXIF data supports it.
        commands.send(:"auto-orient")
        commands = commands + "repage"
      end
    end
    
    protected
    
    def copy_temp_from_storage
      @temp_file = Tempfile.new "has_image_processor_#{geometry}"
      @temp_file.write(@storage.temp_file.read)
      @temp_file.close
    end
    
  end

end