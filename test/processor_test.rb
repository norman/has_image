require 'rubygems'
require 'mocha'
require 'active_support'
require 'stringio'
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/has_image/processor'
require 'fileutils'

class StorageTest < Test::Unit::TestCase
  
  def teardown
    @temp_file.close if @temp_file
  end
  
  def stub_storage
    @temp_file = Tempfile.new('test')
    @temp_file.write(File.new(File.dirname(__FILE__) + "/fixtures/image.jpg", "r").read)
    stub(:temp_file => @temp_file)
  end
  
  def test_create_thumbnail
    @processor = HasImage::Processor.new
    @processor.storage = stub_storage
    @image = @processor.create_thumbnail("400x200")
    assert @image
  end
  
end
