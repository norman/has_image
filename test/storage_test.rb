require 'test_helper.rb'

class StorageTest < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
    FileUtils.rm_rf(File.dirname(__FILE__) + '/../tmp')
    @temp_file.close! if @temp_file && !@temp_file.closed?
  end
  
  def default_options
    HasImage.default_options_for("tests").merge(
      :base_path => File.join(File.dirname(__FILE__), '..', 'tmp')
    )
  end
  
  def test_partitioned_path
    assert_equal(["0001", "2345"], HasImage::Storage.partitioned_path("12345"))
  end
  
  def test_random_file_name
    assert_match(/[a-z0-9]{4,6}/i, HasImage::Storage.random_file_name)
  end
  
  def test_path_for
    @storage = HasImage::Storage.new(default_options)
    assert_match(/\/tmp\/tests\/0000\/0001/, @storage.send(:path_for, 1))
  end
  
  def test_public_path_for
    @storage = HasImage::Storage.new(default_options)
    pic = stub(:has_image_file => "mypic", :id => 1)
    assert_equal "/tests/0000/0001/mypic_square.jpg", @storage.public_path_for(pic, :square)
  end
  
  def test_filename_for
    @storage = HasImage::Storage.new(default_options)
    assert_equal "test.jpg", @storage.send(:file_name_for, "test")
  end

  def test_set_data_from_file
    @storage = HasImage::Storage.new(default_options)
    @file = File.new(File.dirname(__FILE__) + "/../test_rails/fixtures/image.jpg", "r")
    @storage.image_data = @file
    assert @storage.temp_file.size > 0
    assert_equal Zlib.crc32(@file.read), Zlib.crc32(@storage.temp_file.read)
  end
  
  def test_set_data_from_tempfile
    @storage = HasImage::Storage.new(default_options)
    @storage.image_data = temp_file("image.jpg")
    assert @storage.temp_file.size > 0
    assert_equal Zlib.crc32(@storage.temp_file.read), Zlib.crc32(@temp_file.read)
  end
  
  def test_install_and_remove_images
    @storage = HasImage::Storage.new(default_options)
    @storage.image_data = temp_file("image.jpg")
    assert @storage.install_images(1)
    assert @storage.remove_images(1)    
  end

  def test_image_not_too_small
    @storage = HasImage::Storage.new(default_options.merge(:min_size => 1.kilobyte))
    @storage.image_data = temp_file("image.jpg")
    assert !@storage.image_too_small?
  end
  
  def test_image_too_small
    @storage = HasImage::Storage.new(default_options.merge(:min_size => 1.gigabyte))
    @storage.image_data = temp_file("image.jpg")
    assert @storage.image_too_small?
  end
  
  def test_image_too_big
    @storage = HasImage::Storage.new(default_options.merge(:max_size => 1.kilobyte))
    @storage.image_data = temp_file("image.jpg")    
    assert @storage.image_too_big?
  end

  def test_image_not_too_big
    @storage = HasImage::Storage.new(default_options.merge(:max_size => 1.gigabyte))
    @storage.image_data = temp_file("image.jpg")    
    assert !@storage.image_too_big?
  end
  
  private
  
  def temp_file(fixture)
    file = File.new(File.dirname(__FILE__) + "/../test_rails/fixtures/#{fixture}", "r")
    @temp_file = Tempfile.new("test")
    @temp_file.write(file.read)
    return @temp_file
  end
  
end