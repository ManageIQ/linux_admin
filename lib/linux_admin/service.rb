# LinuxAdmin Service Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

class LinuxAdmin
  class Service < LinuxAdmin
    attr_accessor :id

    private

    public

    def initialize(id)
      @id = id
    end

    def running?
      run(cmd(:service),
          :params => { nil => [id, "status"] }).exit_status == 0
    end

    def enable
      run!(cmd(:chkconfig),
          :params => { nil => [id, "on"] })
      self
    end

    def disable
      run!(cmd(:chkconfig),
          :params => { nil => [id, "off"] })
      self
    end

    def start
      run!(cmd(:service),
          :params => { nil => [id, "start"] })
      self
    end

    def start_and_detach
      detach(cmd(:service),
             :params => [id, "start"])
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
