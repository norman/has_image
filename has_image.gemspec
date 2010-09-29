require File.expand_path("../lib/has_image/version", __FILE__)

Gem::Specification.new do |s|
  s.authors           = ['Norman Clarke', 'Adrián Mugnolo']
  s.date              = "2010-09-29"
  s.description       = 'Has_image is a Ruby on Rails gem/plugin that allows you to attach images to Active Record models.'
  s.email             = ['norman@njclarke.com', 'adrian@mugnolo.com']
  s.files             = Dir["lib/**/*.rb", "*.md", "MIT-LICENSE", "Rakefile", "test/**/*.*"]
  s.has_rdoc          = true
  s.homepage          = 'http://github.com/norman/has_image'
  s.name              = "has_image"
  s.rubyforge_project = 'has-image'
  s.summary           = "Lets you attach images with thumbnails to Active Record models."
  s.version           = HasImage::VERSION

  s.add_dependency    'mini_magick', '~> 2.1'
  s.add_dependency    'activesupport', '>= 2.1.0'
  s.add_dependency    'activerecord', '>= 2.1.0'

  s.add_development_dependency "mocha"
end
