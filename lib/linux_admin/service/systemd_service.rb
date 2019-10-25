module LinuxAdmin
  class SystemdService < Service
    def running?
      Common.run(command_path, :params => ["status", name]).success?
    end

    def enable
      Common.run!(command_path, :params => ["enable", name])
      self
    end

    def disable
      Common.run!(command_path, :params => ["disable", name])
      self
    end

    def start(enable = false)
      if enable
        Common.run!(command_path, :params => ["enable", "--now", name])
      else
        Common.run!(command_path, :params => ["start", name])
      end
      self
    end

    def stop
      Common.run!(command_path, :params => ["stop", name])
      self
    end

    def restart
      status = Common.run(command_path, :params => ["restart", name]).exit_status

      # attempt to manually stop/start if restart fails
      if status != 0
        stop
        start
      end

      self
    end

    def reload
      Common.run!(command_path, :params => ["reload", name])
      self
    end

    def status
      Common.run(command_path, :params => ["status", name]).output
    end

    def show
      output = Common.run!(command_path, :params => ["show", name]).output
      output.split("\n").each_with_object({}) do |line, h|
        k, v = line.split("=", 2)
        h[k] = cast_show_value(k, v)
      end
    end

    private

    def command_path
      Common.cmd(:systemctl)
    end

    def cast_show_value(key, value)
      return value.to_i if value =~ /^\d+$/

      case key
      when /^.*Timestamp$/
        Time.parse(value)
      when /Exec(Start|Stop)/
        parse_exec_value(value)
      else
        value
      end
    end

    def parse_exec_value(value)
      value[1..-2].strip.split(" ; ").map { |s| s.split("=", 2) }.to_h
    end
  end
end
