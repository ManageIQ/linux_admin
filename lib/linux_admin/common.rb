require 'awesome_spawn'

module LinuxAdmin
  module Common
    BIN_DIRS = %w(/bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin)

    def cmd(name)
      BIN_DIRS.collect { |dir| "#{dir}/#{name}" }.detect { |cmd| File.exist?(cmd) }
    end

    def cmd?(name)
      !cmd(name).nil?
    end

    def run(cmd, options = {})
      AwesomeSpawn.logger ||= logger
      AwesomeSpawn.run(cmd, options)
    end

    def run!(cmd, options = {})
      AwesomeSpawn.logger ||= logger
      AwesomeSpawn.run!(cmd, options)
    end
  end
end
