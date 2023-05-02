require 'awesome_spawn'

module LinuxAdmin
  module Common
    include Logging

    BIN_DIRS = ENV["PATH"].split(File::PATH_SEPARATOR).freeze

    def self.cmd(name)
      BIN_DIRS.collect { |dir| "#{dir}/#{name}" }.detect { |cmd| File.exist?(cmd) }
    end

    def self.cmd?(name)
      !cmd(name).nil?
    end

    def self.run(cmd, options = {})
      AwesomeSpawn.logger ||= logger
      AwesomeSpawn.run(cmd, options)
    end

    def self.run!(cmd, options = {})
      AwesomeSpawn.logger ||= logger
      AwesomeSpawn.run!(cmd, options)
    end
  end
end
