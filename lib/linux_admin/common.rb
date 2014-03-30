require 'awesome_spawn'

class LinuxAdmin
  module Common
    def cmd(cmd)
      Distros.local.class::COMMANDS[cmd]
    end

    def run(cmd, options = {})
      AwesomeSpawn.run(cmd, options)
    end

    def run!(cmd, options = {})
      AwesomeSpawn.run!(cmd, options)
    end
  end
end
