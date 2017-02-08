module LinuxAdmin
  class SystemdService < Service
    def running?
      Common.run(command_path, :params => {nil => ["status", name]}).success?
    end

    def enable
      Common.run!(command_path, :params => {nil => ["enable", name]})
      self
    end

    def disable
      Common.run!(command_path, :params => {nil => ["disable", name]})
      self
    end

    def start
      Common.run!(command_path, :params => {nil => ["start", name]})
      self
    end

    def stop
      Common.run!(command_path, :params => {nil => ["stop", name]})
      self
    end

    def restart
      status = Common.run(command_path, :params => {nil => ["restart", name]}).exit_status

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

    private

    def command_path
      Common.cmd(:systemctl)
    end
  end
end
