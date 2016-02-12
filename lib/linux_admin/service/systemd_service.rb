module LinuxAdmin
  class SystemdService < Service
    def running?
      Common.run(Common.cmd(:systemctl),
                 :params => {nil => ["status", name]}).exit_status == 0
    end

    def enable
      Common.run!(Common.cmd(:systemctl),
                  :params => {nil => ["enable", name]})
      self
    end

    def disable
      Common.run!(Common.cmd(:systemctl),
                  :params => {nil => ["disable", name]})
      self
    end

    def start
      Common.run!(Common.cmd(:systemctl),
                  :params => {nil => ["start", name]})
      self
    end

    def stop
      Common.run!(Common.cmd(:systemctl),
                  :params => {nil => ["stop", name]})
      self
    end

    def restart
      status =
        Common.run(Common.cmd(:systemctl),
                   :params => {nil => ["restart", name]}).exit_status

      # attempt to manually stop/start if restart fails
      if status != 0
        stop
        start
      end

      self
    end

    def reload
      Common.run!(Common.cmd(:systemctl), :params => ["reload", name])
      self
    end

    def status
      Common.run(Common.cmd(:systemctl), :params => ["status", name]).output
    end
  end
end
