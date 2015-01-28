require 'awesome_spawn'

module LinuxAdmin
  module Common
    attr_writer :logger

    def logger
      @logger ||= LinuxAdmin.logger
    end

    def cmd(cmd)
      Distros.local.command(cmd)
    end

    def run(cmd, options = {})
      AwesomeSpawn.run(cmd, options)
    end

    def run!(cmd, options = {})
      AwesomeSpawn.logger = logger
      AwesomeSpawn.run!(cmd, options)
    end
  end
end
