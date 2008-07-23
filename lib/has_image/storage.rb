require 'active_support'
require 'stringio'
require 'fileutils'

module HasImage  
  
  class StorageError < StandardError ; end
  
  class Storage
    
    attr_accessor :image_data, :options, :temp_file

    class << self
      
      # From Jamis Buck. http://www.37signals.com/svn/archives2/id_partitioning.php
      def partitioned_path(id, *args)
        ("%08d" % id).scan(/..../) + args
      end

      def random_file_name
        require 'zlib'
        Zlib.crc32(Time.now.to_s + rand(10e10).to_s).to_s(36)
      end
          
    end

    def initialize(options)
      @options = options
    end

    def image_data=(image_data)
      raise StorageError.new if image_data.blank?
      if image_data.is_a?(Tempfile)
        @temp_file = image_data
      else
        image_data.rewind
        @temp_file = Tempfile.new 'has_image_data_%s' % Storage.random_file_name
        @temp_file.write(image_data.read)        
      end
    end
    
    def install_images(id)
      random_name = Storage.random_file_name
      install_main_image(id, random_name)
      install_thumbnails(id, random_name) if !options[:thumbnails].empty?
      return random_name
    ensure  
      @temp_file.close! if !@temp_file.closed?
    end

    def filesystem_path_for(object, thumbnail = nil)
      File.join(path_for(object.id), file_name_for(object.file_name, thumbnail))
    end
    
    def public_path_for(object, thumbnail = nil)
      filesystem_path_for(object, thumbnail).gsub(options[:base_path], '')
    end
    
    def remove_images(id)
      FileUtils.rm_r path_for(id)
    end
    
    private
    
    def extension
      options[:convert_to].to_s.downcase.gsub("jpeg", "jpg")
    end

    def file_name_for(*args)
      "%s.%s" % [args.compact.join("_"), extension]
    end
    
    def install_main_image(id, name)
      FileUtils.mkdir_p path_for(id)
      main = processor.resize(@temp_file, @options[:resize_to])
      main.write(File.join(path_for(id), file_name_for(name)))
      main.tempfile.close!
    end
    
    def install_thumbnails(id, name)
      FileUtils.mkdir_p path_for(id)
      path = File.join(path_for(id), file_name_for(name))
      options[:thumbnails].each do |thumb_name, size|
        thumb = processor.resize(path, size)
        thumb.write(File.join(path_for(id), file_name_for(name, thumb_name)))
        thumb.tempfile.close!
      end
    end
    
    def path_for(id)
      File.join(options[:base_path], options[:path_prefix], Storage.partitioned_path(id))
    end
    
    def processor
      @processor ||= Processor.new(options)
    end
    
  end
  
end