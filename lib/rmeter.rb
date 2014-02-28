require File.join(File.dirname(__FILE__), './rmeter/version')
require 'rubygems'
require 'bundler/setup'

#common dependencies
require "csv"
require 'launchy'
require "curb"

#internal dependences
require File.join(File.dirname(__FILE__), './rmeter/tasks/ssh.rake')

module RMeter 
end
