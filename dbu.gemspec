# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dbu/version'

Gem::Specification.new do |spec|
  spec.name          = "dbu"
  spec.version       = Dbu::VERSION
  spec.authors       = ["Simon Chiang"]
  spec.email         = ["simon.a.chiang@gmail.com"]
  spec.description   = %q{Database Utility}
  spec.summary       = %q{Database Utility}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = ['dbu']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
