require 'test_helper'

class CustomFileNameColumnTest < Test::Unit::TestCase

  def test_create_with_custom_file_name_column
    @person = Person.new(:name => "John Doe", :image_data => fixture_file_upload("/image.jpg", "image/jpeg"))
    assert @person.save!
    assert @person.picture
  end

end
