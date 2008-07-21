require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/pic'


class PicTest < Test::Unit::TestCase
  
  def setup
    Pic.has_image_options[:base_path] = RAILS_ROOT + '/tmp'
  end
  
  def test_valid
    @pic = Pic.new
    assert @pic.valid?
  end
  
  def test_create
    image = "/../../test/fixtures/image.jpg"
    @pic = Pic.new(:name => "test", :image_data => fixture_file_upload(image, "image/jpeg"))
    @pic.save!
  end
  
end