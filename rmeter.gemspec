# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rmeter/version"

Gem::Specification.new do |s|
  s.name        = "rmeter"
  s.version     = RMeter::VERSION
  s.authors     = ["Camilo Ribeiro"]
  s.email       = ["camilo@camiloribeiro.com"]
  s.homepage    = "http://github.com/camiloribeiro/rmeter"
  s.license     = "Apache 2.0"
  s.summary     = %q{Ruby wraper to run multiserver jmeter tests with nice reports}
  s.description = %q{RMeter is a ruby based implementation of a jmeter multi-server runner, with reports and some spice}

  s.rubyforge_project = "cello"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.default_executable = 'rmeter'

  s.require_paths = ["lib"]

  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec'

 s.add_dependency 'rake'
 s.add_dependency 'redcarpet'
 s.add_dependency 'launchy'
 s.add_dependency 'groupdate'
 s.add_dependency "chartkick"
 s.add_dependency "curb"

end
