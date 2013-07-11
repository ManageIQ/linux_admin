# LinuxAdmin Service Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

class LinuxAdmin
  class Service < LinuxAdmin
    attr_accessor :id

    def initialize(id)
      @id = id
    end

    def running?
      run(cmd(:service),
          :params => { nil => [id, "status"] },
          :return_exitstatus => true) == 0
    end

    def enable
      run(cmd(:systemctl),
          :params => { nil => ["enable", "#{id}.service"] })
      self
    end

    def disable
      run(cmd(:systemctl),
          :params => { nil => ["disable", "#{id}.service"] })
      self
    end

    def start
      run(cmd(:service),
          :params => { nil => [id, "start"] })
      self
    end

    def stop
      run(cmd(:service),
          :params => { nil => [id, "stop"] })
      self
    end

    def restart
      status =
        run(cmd(:service),
          :params => { nil => [id, "restart"] },
          :return_exitstatus => true)

      # attempt to manually stop/start if restart fails
      if status != 0
        self.stop
        self.start
      end

      self
    end
  end
end
