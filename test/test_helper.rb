require 'rubygems'
require 'bundler/setup'
require "active_support/core_ext/kernel/reporting"
require "active_support/core_ext/class/attribute_accessors"
require 'test/unit'
require 'mocha'
require "active_record"
require "logger"
require "rack/test"
require "pathname"

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require "has_image"

module Rails
  extend self
  def root
    Pathname(File.join(File.dirname(__FILE__), '..', 'tmp'))
  end
end

ActiveRecord::Base.logger = Logger.new($stdout) if ENV["LOG"]
ActiveRecord::Migration.verbose = false

# Change the connection args as you see fit to test against different adapters.
ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => ":memory:"
)

module ActionView
  class Base
  end
end

ActiveRecord::Migration.create_table :pics do |t|
  t.string  :has_image_file
  t.timestamps
end

ActiveRecord::Migration.create_table :complex_pics do |t|
  t.string :filename
  t.integer :width, :height
  t.string :image_size
  t.timestamps
end

HasImage.enable

def fixture_file_upload(path, mime_type)
  path = File.expand_path("../fixtures/#{path}", __FILE__)
  Rack::Test::UploadedFile.new(path, mime_type)
end