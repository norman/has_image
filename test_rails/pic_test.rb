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
    @pic = Pic.new(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert @pic.valid? , "#{@pic.errors.full_messages.to_sentence}"
  end

  def test_should_be_too_big
    Pic.has_image_options[:max_size] = 1.kilobyte
    @pic = Pic.new(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert !@pic.valid?
  end

  def test_should_be_too_small
    Pic.has_image_options[:min_size] = 1.gigabyte
    @pic = Pic.new(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert !@pic.valid?
  end

  def test_invalid_image_detected
    @pic = Pic.new(:image_data => fixture_file_upload("/bad_image.jpg", "image/jpeg"))
    assert !@pic.valid?
  end

  def test_create
    @pic = Pic.new(:image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert @pic.save!
  end

  def test_create_model_without_setting_image_data
    assert Pic.new.save!
  end

  def test_destroy_model_without_no_images
    @pic = Pic.new
    @pic.save!
    assert @pic.destroy
  end

  def test_destroy_model_with_images_already_deleted_from_filesystem
    @pic = Pic.new
    @pic.save!
    @pic.update_attribute(:file_name, "test")
    assert @pic.destroy
  end

  def test_create_with_png
    Pic.has_image_options[:min_size] = 1
    @pic = Pic.new(:image_data => fixture_file_upload("/image.png", "image/png"))
    assert @pic.save!
  end

  def test_multiple_calls_to_valid_doesnt_blow_away_temp_image
    Pic.has_image_options[:min_size] = 1
    @pic = Pic.new(:image_data => fixture_file_upload("/image.png", "image/png"))
    @pic.valid?
    assert @pic.valid?
  end

end

