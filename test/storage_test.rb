require 'test/unit'
require File.dirname(__FILE__) + '/../lib/has_image/storage'

class StorageTest < Test::Unit::TestCase
  
  def setup
  end
  
  def test_partitioned_path
    assert HasImage::Storage.partitioned_path("12345")
  end
  
  def test_random_file_name
    assert HasImage::Storage.random_file_name
  end

  def test_set_data_from_file
    @storage = HasImage::Storage.new
    @file = File.new(File.dirname(__FILE__) + "/fixtures/image.jpg", "r")
    @storage.data = @file
    assert @storage.temp_file.size > 0
    assert_equal Zlib.crc32(@file.read), Zlib.crc32(@storage.temp_file.read)
  ensure
    @storage.temp_file.close!
  end
  
  def test_set_data_from_tempfile
    @storage = HasImage::Storage.new
    @file = File.new(File.dirname(__FILE__) + "/fixtures/image.jpg", "r")
    @temp_file = Tempfile.new("test")
    @temp_file.write(@file.read)
    @storage.data = @temp_file
    assert @storage.temp_file.size > 0
    assert_equal Zlib.crc32(@storage.temp_file.read), Zlib.crc32(@temp_file.read)
  ensure
    @temp_file.close!
  end

  
end
