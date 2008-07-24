class Person < ActiveRecord::Base
  has_image :file_name_column => :picture
end