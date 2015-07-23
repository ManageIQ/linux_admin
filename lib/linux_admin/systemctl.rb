module LinuxAdmin
  class Systemctl
    include Common

    attr_accessor :id

    public

    def initialize(id)
      @id = id
    end

    def running?
      run(cmd(:systemctl),
          :params => {nil => ["status", id]}).exit_status == 0
    end

    def enable
      run!(cmd(:systemctl),
           :params => {nil => ["enable", id]})
      self
    end

    def disable
      run!(cmd(:systemctl),
           :params => {nil => ["disable", id]})
      self
    end

    def start
      run!(cmd(:systemctl),
           :params => {nil => ["start", id]})
      self
    end

    def stop
      run!(cmd(:systemctl),
           :params => {nil => ["stop", id]})
      self
    end

    def restart
      status =
        run(cmd(:systemctl),
            :params => {nil => ["restart", id]}).exit_status

      # attempt to manually stop/start if restart fails
      if status != 0
        stop
        start
      end

      self
    end
  end
end
