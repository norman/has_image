Gem::Specification.new do |s|
  s.name = "has_image"
  s.version = "0.0.1"
  s.date = "2008-07-21"
  s.summary = "Lets you attach images with thumbnails to active record models."
  s.email = 'norman@randomba.org'
  s.homepage = 'http://randomba.org'
  s.description = 'HasImage is a gem/plugin for Rails for attached images, like a super-lightweight attachment_fu for images only.'
  s.has_rdoc = true
  s.authors = ['Norman Clarke']
  s.files = [
    "MIT-LICENSE",
    "README",
    "init.rb",
    "lib/has_image.rb",
    "lib/has_image/processor.rb",
    "lib/has_image/storage.rb",
    "rails/init.rb",
    "Rakefile",
    "tasks/has_image_tasks.rake"
    ]
  s.test_files = [
    "rails-test/database.yml",
    "rails-test/fixtures/empty",
    "rails-test/pic.rb",
    "rails-test/pic_test.rb",
    "rails-test/schema.rb",
    "rails-test/test_helper.rb",
    "test/fixtures/image.jpg",
    "test/has_image_test.rb",
    "test/processor_test.rb",
    "test/storage_test.rb",
  ]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]

end
