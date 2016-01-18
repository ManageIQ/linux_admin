module LinuxAdmin
  class SysVInitService < Service
    def running?
      run_cmd(name, "status")
    end

    def enable
      Common.run!(Common.cmd(:chkconfig), :params => [name, "on"])
      self
    end

    def disable
      Common.run!(Common.cmd(:chkconfig), :params => [name, "off"])
      self
    end

    def start
      run_cmd!(name, "start")
    end

    def stop
      run_cmd!(name, "stop")
    end

    def restart
      # attempt to manually stop/start if restart fails
      unless run_cmd(name, "restart")
        self.stop
        self.start
      end

      self
    end

    private

    def run_cmd(*actions)
      Common.run(Common.cmd(:service), :params => actions).success?
    end

    def run_cmd!(*actions)
      Common.run!(Common.cmd(:service), :params => actions)
      self
    end
  end
end
