require File.join(File.dirname(__FILE__), './cello/version')
require 'rubygems'
require 'bundler/setup'

#common dependencies
require 'dependencies'

#internal dependences
require File.join(File.dirname(__FILE__), './reter/foo/bar')

module RMeter 
end
