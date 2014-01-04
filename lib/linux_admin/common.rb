require 'awesome_spawn'

class LinuxAdmin
  module Common
    def cmd(cmd)
      Distro.local.class::COMMANDS[cmd]
    end

    def run(cmd, options = {})
      AwesomeSpawn.run(cmd, options)
    end

    def run!(cmd, options = {})
      AwesomeSpawn.run!(cmd, options)
    end
  end
end
