require 'bundler/setup'
Bundler.require

PROJECT_NAME = 'example'

MASTER = 'stress01'
NODES = %w[stress01 stress02 stress03 stress04]
TARGET_HOST = 'http://example.com'

Dir[File.join(File.dirname(__FILE__), 'lib', 'tasks', '**/*.rake')].each {|f| load f }
task :default => 'sync:run'
