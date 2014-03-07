require 'awesome_spawn'

class LinuxAdmin
  module Common
    def cmd(cmd)
      Distro.local.commands[cmd] || raise(ArgumentError, "command #{cmd} not defined for #{Distro.local.id}")
    end

    def run(cmd, options = {})
      AwesomeSpawn.run(cmd, options)
    end

    def run!(cmd, options = {})
      AwesomeSpawn.run!(cmd, options)
    end
  end
end
