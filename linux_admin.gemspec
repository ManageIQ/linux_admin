# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'linux_admin/version'

Gem::Specification.new do |spec|

  # Dynamically create the authors information {name => e-mail}
  authors_hash = Hash[`git log --no-merges --reverse --format='%an,%ae'`.split("\n").uniq.collect {|i| i.split(",")}]

  spec.name          = "linux_admin"
  spec.version       = LinuxAdmin::VERSION
  spec.authors       = authors_hash.keys
  spec.email         = authors_hash.values
  spec.description   = %q{
LinuxAdmin is a module to simplify management of linux systems.
It should be a single place to manage various system level configurations,
registration, updates, etc.
}
  spec.summary       = %q{LinuxAdmin is a module to simplify management of linux systems.}
  spec.homepage      = "http://github.com/ManageIQ/linux_admin"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",  "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec",    "~> 2.13"
  spec.add_development_dependency "coveralls"

  spec.add_dependency "activesupport",        "> 3.2"
  spec.add_dependency "inifile",              "~> 2.0.2"
  spec.add_dependency "more_core_extensions", "~> 1.1.2"
  spec.add_dependency "awesome_spawn",        "~> 1.1.0"
  spec.add_dependency "nokogiri"
end
