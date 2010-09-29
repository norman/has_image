require 'rake'
require 'rake/testtask'
require "rake/gempackagetask"
require "rake/clean"

CLEAN << "pkg" << "doc" << "coverage"
Rake::GemPackageTask.new(eval(File.read("has_image.gemspec"))) { |pkg| }

task :default => :test

desc 'Test the non-Rails part of has_image.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end