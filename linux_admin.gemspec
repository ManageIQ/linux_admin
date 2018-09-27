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

  spec.files         = `git ls-files -- lib/*`.split("\n")
  spec.files        += %w[README.md LICENSE.txt]
  spec.executables   = `git ls-files -- bin/*`.split("\n")
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_development_dependency "bundler",  "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec",    "~> 3.0"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "rubocop",  "~> 0.53.0"

  spec.add_dependency "awesome_spawn",        "~> 1.3"
  spec.add_dependency "inifile"
  spec.add_dependency "more_core_extensions", "~> 3.0"
  spec.add_dependency "nokogiri",             ">= 1.8.2", "~> 1.8"
  spec.add_dependency "openscap"
  spec.add_dependency "net-ssh", "~> 4.2.0"
end
