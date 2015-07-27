module LinuxAdmin
  class SysVInitService < Service
    def running?
      run(cmd(:service),
          :params => { nil => [name, "status"] }).exit_status == 0
    end

    def enable
      run!(cmd(:chkconfig),
          :params => { nil => [name, "on"] })
      self
    end

    def disable
      run!(cmd(:chkconfig),
          :params => { nil => [name, "off"] })
      self
    end

    def start
      run!(cmd(:service),
          :params => { nil => [name, "start"] })
      self
    end

    def stop
      run!(cmd(:service),
          :params => { nil => [name, "stop"] })
      self
    end

    def restart
      status =
        run(cmd(:service),
          :params => { nil => [name, "restart"] }).exit_status

      # attempt to manually stop/start if restart fails
      if status != 0
        self.stop
        self.start
      end

      self
    end
  end
end
