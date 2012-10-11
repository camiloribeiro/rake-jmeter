Dir[File.dirname(__FILE__) + "/config/*.rb"].each do |file|
  require file 
end
require "bundler/setup"
Bundler.require

TARGET_HOST = "foo"

Dir[File.join(File.dirname(__FILE__), 'lib', 'tasks', '**/*.rake')].each {|f| load f }

task :default => ['ssh:check', 'version:print', 'sync:run']
