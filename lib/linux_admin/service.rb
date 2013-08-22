# LinuxAdmin Service Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

class LinuxAdmin
  class Service < LinuxAdmin
    attr_accessor :id

    private

    def systemctl(cmd)
      run!(cmd(:systemctl),
          :params => { nil => [cmd, "#{id}.service"] })
    end

    public

    def initialize(id)
      @id = id
    end

    def running?
      run(cmd(:service),
          :params => { nil => [id, "status"] }).exit_status == 0
    end

    def enable
      systemctl 'enable'
      self
    end

    def disable
      systemctl 'disable'
      self
    end

    def start
      run!(cmd(:service),
          :params => { nil => [id, "start"] })
      self
    end

    def stop
      run!(cmd(:service),
          :params => { nil => [id, "stop"] })
      self
    end

    def restart
      status =
        run(cmd(:service),
          :params => { nil => [id, "restart"] }).exit_status

      # attempt to manually stop/start if restart fails
      if status != 0
        self.stop
        self.start
      end

      self
    end
  end
end
