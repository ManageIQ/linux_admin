module LinuxAdmin
  class Systemctl
    include Common

    attr_accessor :name

    public

    def initialize(name)
      @name = name
    end

    def running?
      run(cmd(:systemctl),
          :params => {nil => ["status", name]}).exit_status == 0
    end

    def enable
      run!(cmd(:systemctl),
           :params => {nil => ["enable", name]})
      self
    end

    def disable
      run!(cmd(:systemctl),
           :params => {nil => ["disable", name]})
      self
    end

    def start
      run!(cmd(:systemctl),
           :params => {nil => ["start", name]})
      self
    end

    def stop
      run!(cmd(:systemctl),
           :params => {nil => ["stop", name]})
      self
    end

    def restart
      status =
        run(cmd(:systemctl),
            :params => {nil => ["restart", name]}).exit_status

      # attempt to manually stop/start if restart fails
      if status != 0
        stop
        start
      end

      self
    end
  end
end
