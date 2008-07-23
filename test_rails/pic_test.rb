require 'test_helper'

class PicTest < Test::Unit::TestCase
  
  def setup
    Pic.has_image_options[:base_path] = File.join(RAILS_ROOT, '/tmp')
  end
  
  def teardown
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'tmp', 'pics'))
  end
  
  def test_should_be_valid
    image = "/../../test/fixtures/image.jpg"
    @pic = Pic.new(:image_data => fixture_file_upload(image, "image/jpeg"))
    assert @pic.valid?
  end

  def test_invalid_image_detected
    image = "/../../test/fixtures/bad_image.jpg"
    @pic = Pic.new(:image_data => fixture_file_upload(image, "image/jpeg"))
    assert !@pic.valid?
  end

  def test_create
    image = "/../../test/fixtures/image.jpg"
    @pic = Pic.new(:image_data => fixture_file_upload(image, "image/jpeg"))
    @pic.save!
  end

  def test_create_with_png
    image = "/../../test/fixtures/image.png"
    @pic = Pic.new(:image_data => fixture_file_upload(image, "image/png"))
    assert @pic.valid?
    @pic.save!
  end

  
end