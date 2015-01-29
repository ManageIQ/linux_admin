require 'awesome_spawn'

module LinuxAdmin
  module Common
    def cmd(cmd)
      Distros.local.command(cmd)
    end

    def run(cmd, options = {})
      AwesomeSpawn.run(cmd, options)
    end

    def run!(cmd, options = {})
      AwesomeSpawn.run!(cmd, options)
    end
  end
end
