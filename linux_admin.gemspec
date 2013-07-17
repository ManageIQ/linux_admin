# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'linux_admin/version'

Gem::Specification.new do |spec|
  spec.name          = "linux_admin"
  spec.version       = LinuxAdmin::VERSION
  spec.authors       = ["Brandon Dunne"]
  spec.email         = ["brandondunne@hotmail.com"]
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

  spec.add_dependency "activesupport",        "< 4.0"
  spec.add_dependency "inifile",              "~> 2.0.2"
  spec.add_dependency "more_core_extensions"
  spec.add_dependency "nokogiri"
  spec.add_dependency "ruby-dbus"
end
