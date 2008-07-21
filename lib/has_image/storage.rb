require 'rubygems'
require 'active_support'
require 'stringio'
require 'fileutils'

module HasImage  
  
  class FileDataError < StandardError ; end
  
  class Storage
    
    attr_accessor :data, :options, :temp_file

    def initialize(options)
      @options = options
    end

    def self.partitioned_path(id, *args)
      ("%08d" % id).scan(/..../) + args
    end

    def self.random_file_name
      require 'zlib'
      Zlib.crc32(Time.now.to_s + rand(10e10).to_s).to_s(36)
    end
    
    def data=(data)
      raise HasImage::FileDataError.new if data.blank?
      if data.is_a?(Tempfile)
        @temp_file = data
      else
        data.rewind
        @temp_file = Tempfile.new 'has_image_data_%s' % Storage.random_file_name
        @temp_file.write(data.read)
      end
    end
    
    def install_images(id)
      random_name = Storage.random_file_name
      install_thumbnails(id, random_name) if !options[:thumbnails].empty?
      install_main_image(id, random_name)
      return file_name_for(random_name)
    end
    
    def public_path_for(object, thumbnail = nil)
      File.join(
        path_for(object.id).gsub(options[:base_path], ''),
        file_name_for(object.file_name, thumbnail)
      )
    end
    
    def remove_images(id)
      FileUtils.rm_r path_for(id)
    end
    
    private
    
    def install_main_image(id, name)
      FileUtils.mkdir_p path_for(id)
      main = processor.resize(:temp_file => @temp_file, :size => @options[:resize_to])
      main.write(File.join(path_for(id), file_name_for(name)))
    end
    
    def install_thumbnails(id, name)
      FileUtils.mkdir_p path_for(id)
      options[:thumbnails].each do |thumb_name, size|
        thumb = processor.resize(:temp_file => @temp_file, :size => size)
        thumb.write(File.join(path_for(id), file_name_for(name, thumb_name)))
      end
    end
    
    def file_name_for(*args)
      "%s.%s" % [args.compact.join("_"), options[:convert_to].to_s.downcase]
    end

    def path_for(id)
      File.join(options[:base_path], options[:path_prefix], Storage.partitioned_path(id))
    end
    
    def processor
      @processor ||= HasImage::Processor.new(options)
    end
    
  end
  
end