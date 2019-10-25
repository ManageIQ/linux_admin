module LinuxAdmin
  class SysVInitService < Service
    def running?
      Common.run(Common.cmd(:service),
                 :params => {nil => [name, "status"]}).exit_status == 0
    end

    def enable
      Common.run!(Common.cmd(:chkconfig),
                  :params => {nil => [name, "on"]})
      self
    end

    def disable
      Common.run!(Common.cmd(:chkconfig),
                  :params => {nil => [name, "off"]})
      self
    end

    def start(enable = false)
      Common.run!(Common.cmd(:service),
                  :params => {nil => [name, "start"]})
      self.enable if enable
      self
    end

    def stop
      Common.run!(Common.cmd(:service),
                  :params => {nil => [name, "stop"]})
      self
    end

    def restart
      status =
        Common.run(Common.cmd(:service),
                   :params => {nil => [name, "restart"]}).exit_status

      # attempt to manually stop/start if restart fails
      if status != 0
        self.stop
        self.start
      end

      self
    end

    def reload
      Common.run!(Common.cmd(:service), :params => [name, "reload"])
      self
    end

    def status
      Common.run(Common.cmd(:service), :params => [name, "status"]).output
    end

    def show
      raise NotImplementedError
    end
  end
end
