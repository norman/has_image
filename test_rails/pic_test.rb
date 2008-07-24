require 'test_helper'

class PicTest < Test::Unit::TestCase
  
  def setup
    Pic.has_image_options = HasImage.default_options_for(Pic)
    Pic.has_image_options[:base_path] = File.join(RAILS_ROOT, '/tmp')
  end
  
  def teardown
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'tmp', 'pics'))
  end
  
  def test_should_be_valid
    image = "/../../test/fixtures/image.jpg"
    @pic = Pic.new(:image_data => fixture_file_upload(image, "image/jpeg"))
    assert @pic.valid? , "#{@pic.errors.full_messages.to_sentence}"
  end

  def test_should_be_too_big
    Pic.has_image_options[:max_size] = 1.kilobyte
    image = "/../../test/fixtures/image.jpg"
    @pic = Pic.new(:image_data => fixture_file_upload(image, "image/jpeg"))
    assert !@pic.valid?
  end

  def test_should_be_too_small
    Pic.has_image_options[:min_size] = 1.gigabyte
    image = "/../../test/fixtures/image.jpg"
    @pic = Pic.new(:image_data => fixture_file_upload(image, "image/jpeg"))
    assert !@pic.valid?
  end

  def test_invalid_image_detected
    image = "/../../test/fixtures/bad_image.jpg"
    @pic = Pic.new(:image_data => fixture_file_upload(image, "image/jpeg"))
    assert !@pic.valid?
  end

  def test_create
    image = "/../../test/fixtures/image.jpg"
    @pic = Pic.new(:image_data => fixture_file_upload(image, "image/jpeg"))
    assert @pic.save!
  end

  def test_create_with_png
    image = "/../../test/fixtures/image.png"
    Pic.has_image_options[:min_size] = 1
    @pic = Pic.new(:image_data => fixture_file_upload(image, "image/png"))
    assert @pic.save!
  end

  def test_multiple_calls_to_valid_doesnt_blow_away_temp_image
    image = "/../../test/fixtures/image.png"
    Pic.has_image_options[:min_size] = 1
    @pic = Pic.new(:image_data => fixture_file_upload(image, "image/png"))
    @pic.valid?
    assert @pic.valid?
  end
  
end