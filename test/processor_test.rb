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
  
  def temp_file
    @temp_file = Tempfile.new('test')
    @temp_file.write(File.new(File.dirname(__FILE__) + "/fixtures/image.jpg", "r").read)
    return @temp_file
  end
  
  def test_resize
    @processor = HasImage::Processor.new({})
    assert @processor.resize(:size => "100x100", :temp_file => temp_file)
  end
  
end
