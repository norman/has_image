require 'rubygems'
require 'mocha'
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/has_image/storage'
require File.dirname(__FILE__) + '/../lib/has_image/processor'

class StorageTest < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
    FileUtils.rm_rf(File.dirname(__FILE__) + '/../tmp')
  end
  
  def default_options
    {
      :resize_to => "300x270",
      :thumbnails => {
        :square => "75x75",
      },
      :max_size => 3.megabytes,
      :min_size => 4.kilobytes,
      :path_prefix => "tests",
      :base_path => File.join(File.dirname(__FILE__), '..', 'tmp'),
      :convert_to => "JPG",
      :output_quality => "85"
    }
  end
  
  def test_partitioned_path
    assert HasImage::Storage.partitioned_path("12345")
  end
  
  def test_random_file_name
    assert HasImage::Storage.random_file_name
  end
  
  def test_path_for
    @storage = HasImage::Storage.new(default_options)
    assert_not_nil @storage.send(:path_for, 1)
  end
  
  def test_public_path_for
    @storage = HasImage::Storage.new(default_options)
    pic = stub(:file_name => "mypic", :id => 1)
    assert_equal "/tests/0000/0001/mypic_square.jpg", @storage.public_path_for(pic, :square)
  end
  
  def test_filename_for
    @storage = HasImage::Storage.new(default_options)
    assert_equal "test.jpg", @storage.send(:file_name_for, "test")
  end

  def test_set_data_from_file
    @storage = HasImage::Storage.new(default_options)
    @file = File.new(File.dirname(__FILE__) + "/fixtures/image.jpg", "r")
    @storage.data = @file
    assert @storage.temp_file.size > 0
    assert_equal Zlib.crc32(@file.read), Zlib.crc32(@storage.temp_file.read)
  ensure
    @storage.temp_file.close!
  end
  
  def test_set_data_from_tempfile
    @storage = HasImage::Storage.new(default_options)
    @file = File.new(File.dirname(__FILE__) + "/fixtures/image.jpg", "r")
    @temp_file = Tempfile.new("test")
    @temp_file.write(@file.read)
    @storage.data = @temp_file
    assert @storage.temp_file.size > 0
    assert_equal Zlib.crc32(@storage.temp_file.read), Zlib.crc32(@temp_file.read)
  ensure
    @temp_file.close!
  end
  
  def test_install_and_remove_images
    @storage = HasImage::Storage.new(default_options)
    @file = File.new(File.dirname(__FILE__) + "/fixtures/image.jpg", "r")
    @temp_file = Tempfile.new("test")
    @temp_file.write(@file.read)
    @storage.data = @temp_file
    assert @storage.install_images(1)
    assert @storage.remove_images(1)    
  ensure
    @temp_file.close!
  end

end