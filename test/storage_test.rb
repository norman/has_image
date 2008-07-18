require 'test/unit'
require 'has_image/storage'

class StorageTest < Test::Unit::TestCase
  
  def setup
  end
  
  def test_partitioned_path
    assert HasImage::Storage.partitioned_path("12345")
  end
  
  def test_random_file_name
    assert HasImage::Storage.random_file_name
  end
  
  def test_initialize_with_string_io
    @storage = HasImage::Storage.new
    @storage.data = StringIO.new(IO.read(File.dirname(__FILE__) + "/fixtures/image.jpg"))
    @storage.temp_file.open
    assert @storage.temp_file.size > 0
  ensure
    @storage.temp_file.close!
  end
  
end
