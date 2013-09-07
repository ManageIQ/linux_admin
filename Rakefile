require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec')
task :test => :spec
task :default => :spec

Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
