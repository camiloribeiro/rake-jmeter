require "./config/env_config" 
require "./config/test_config" 
require "./config/config_helper" 
require "bundler/setup"
require "csv"
require 'launchy'

Bundler.require

TARGET_HOST = "foo"

Dir[File.join(File.dirname(__FILE__), 'lib', 'tasks', '**/*.rake')].each {|f| load f }

task :default => ['ssh:check', 'sync:run']
