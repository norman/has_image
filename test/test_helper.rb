require 'rubygems'
require 'bundler/setup'
require 'has_image'
require "active_support/core_ext/kernel/reporting"
require 'test/unit'
require 'mocha'

RAILS_ROOT = File.join(File.dirname(__FILE__), '..', 'tmp')
