require File.dirname(__FILE__) + '/../lib/has_image/processor'
require 'mocha'
require 'test/unit'
require 'activesupport'

class StorageTest < Test::Unit::TestCase
  
  def teardown
    @temp_file.close if @temp_file
    FileUtils.rm_rf(File.dirname(__FILE__) + '/../tmp')
  end
  
  def temp_file(fixture)
    @temp_file = Tempfile.new('test')
    @temp_file.write(File.new(File.dirname(__FILE__) + "/fixtures/#{fixture}", "r").read)
    return @temp_file
  end
  
  def test_detect_valid_image
    assert HasImage::Processor.valid?(File.dirname(__FILE__) + "/fixtures/image.jpg")
  end

  def test_detect_valid_image_from_tmp_file
    assert HasImage::Processor.valid?(temp_file("image.jpg"))
  end

  def test_detect_invalid_image
    assert !HasImage::Processor.valid?(File.dirname(__FILE__) + "/fixtures/bad_image.jpg")
  end

  def test_detect_invalid_image_from_tmp_file
    assert !HasImage::Processor.valid?(temp_file("bad_image.jpg"))
  end
  
  def test_resize
    @processor = HasImage::Processor.new({:convert_to => "JPEG", :output_quality => "85"})
    assert @processor.resize(:size => "100x100", :temp_file => temp_file("image.jpg"))
  end

  def test_resize_and_convert
    @processor = HasImage::Processor.new({:convert_to => "JPEG", :output_quality => "85"})
    assert @processor.resize(:size => "100x100", :temp_file => temp_file("image.png"))
  end

  def test_resize_should_fail_with_bad_image
    @processor = HasImage::Processor.new({:convert_to => "JPEG", :output_quality => "85"})
    assert_raises HasImage::ProcessorError do
      @processor.resize(:size => "100x100", :temp_file => temp_file("bad_image.jpg"))
    end
  end

end