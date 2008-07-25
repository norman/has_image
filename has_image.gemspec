Gem::Specification.new do |s|
  s.name = "has_image"
  s.version = "0.1.0"
  s.date = "2008-07-23"
  s.summary = "Lets you attach images with thumbnails to active record models."
  s.email = 'norman@randomba.org'
  s.homepage = 'http://randomba.org'
  s.description = 'HasImage is a Ruby on Rails gem/plugin that allows you to attach images to ActiveRecord models.'
  s.has_rdoc = true
  s.authors = ['Norman Clarke']
  s.files = [
    "MIT-LICENSE",
    "README",
    "FAQ",
    "init.rb",
    "lib/has_image.rb",
    "lib/has_image/processor.rb",
    "lib/has_image/storage.rb",
    "lib/has_image/view_helpers.rb",
    "Rakefile",
    "tasks/has_image_tasks.rake"
    ]
  s.test_files = [
    "test_rails/database.yml",
    "test_rails/fixtures/empty",
    "test_rails/pic.rb",
    "test_rails/pic_test.rb",
    "test_rails/schema.rb",
    "test_rails/test_helper.rb",
    "test/fixtures/bad_image.jpg",
    "test/fixtures/image.jpg",
    "test/fixtures/image.png",
    "test/processor_test.rb",
    "test/storage_test.rb",
  ]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README", "FAQ"]

end
