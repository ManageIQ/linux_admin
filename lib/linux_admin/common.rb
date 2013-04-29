module LinuxAdmin
  module Common
    def self.run(cmd, options = {})
      begin
        pid, status = Process.wait2(Kernel.spawn(cmd))
        if options[:return_exitstatus] || status.exitstatus == 0
          status.exitstatus
        else
          raise "Error: Exit Code #{status.exitstatus}"
        end
      rescue
        return nil if options[:return_exitstatus]
        raise
      end
    end
  end
end