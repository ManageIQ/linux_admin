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
    end

    def disable
      run(cmd(:systemctl),
          :params => { nil => ["disable", "#{id}.service"] })
    end

    def start
      run(cmd(:service),
          :params => { nil => [id, "start"] })
    end

    def stop
      run(cmd(:service),
          :params => { nil => [id, "stop"] })
    end
  end
end
