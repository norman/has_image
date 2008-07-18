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
      @data = data
      raise FileDataError.new unless data_valid?      
      @data.is_a?(StringIO) ? read_from_string_io : @temp_file = data
    end

    def data_valid?
      !@data.blank?
    end
    
    def read_from_string_io
      @data.rewind
      Tempfile.open 'has_image_data' do |@temp_file|
        @temp_file.write(@data.read)
      end
    end
  
  end
  
end