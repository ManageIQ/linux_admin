module LinuxAdmin
  module Common
    def self.run(cmd)
      begin
        pid, status = Process.wait2 Kernel.spawn(cmd)
        status.exitstatus
      rescue
        return 1
      end
    end
  end
end