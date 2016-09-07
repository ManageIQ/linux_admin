source 'https://rubygems.org'

# Specify your gem's dependencies in linux_admin.gemspec
gemspec

# HACK: Rails 5 dropped support for Ruby < 2.2.2
active_support_version = "< 5" if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.2.2")
gem 'activesupport', active_support_version
