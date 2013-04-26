module LinuxAdmin
  module Common
    def self.run(cmd, options = {})
      begin
        r, w = IO.pipe
        pid, status = Process.wait2(Kernel.spawn(cmd, :err => [:child, :out], :out => w))
        w.close
        if options[:return_output] && status.exitstatus == 0
          r.read
        elsif options[:return_exitstatus] || status.exitstatus == 0
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