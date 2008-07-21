require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/pic'


class PicTest < Test::Unit::TestCase
  
  def test_valid
    @pic = Pic.new
    assert @pic.valid?
  end
  
  def test_default_path_prefix
    assert_equal "pics", Pic.has_image_options[:path_prefix]
  end

  def test_default_path_prefix
    assert_equal File.join(RAILS_ROOT, "public"), Pic.has_image_options[:base_path]
  end
  
end