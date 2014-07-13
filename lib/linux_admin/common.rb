require 'awesome_spawn'

class LinuxAdmin
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

    # NOTE: only currently supports options: :params => []
    def detach(cmd, options = {})
      params = Array(options[:params])
      Process.detach(Kernel.spawn(
        "#{cmd} #{params.join(" ")}",
        [:out, :err] => ["/dev/null", "w"]))
    end
  end
end
