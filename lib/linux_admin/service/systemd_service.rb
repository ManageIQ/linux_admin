module LinuxAdmin
  class SystemdService < Service
    def running?
      run_cmd("status", name)
    end

    def enable
      run_cmd!("enable", name)
    end

    def disable
      run_cmd!("disable", name)
    end

    def start
      run_cmd!("start", name)
    end

    def stop
      run_cmd!("stop", name)
    end

    def restart
      # attempt to manually stop/start if restart fails
      unless run_cmd("restart", name)
        stop
        start
      end

      self
    end

    private

    def run_cmd(*actions)
      Common.run(Common.cmd(:systemctl), :params => actions).success?
    end

    def run_cmd!(*actions)
      Common.run!(Common.cmd(:systemctl), :params => actions)
      self
    end
  end
end
