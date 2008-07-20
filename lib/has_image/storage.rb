require 'rubygems'
require 'active_support'
require 'stringio'

module HasImage  
  
  class FileDataError < StandardError ; end
  
  class Storage
    
    attr_accessor :data, :temp_file

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
  end
  
end