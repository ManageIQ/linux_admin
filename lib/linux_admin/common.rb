module LinuxAdmin
  module Common
    def self.run(cmd)
      begin
        pid = Kernel.spawn(cmd)
        Process.wait pid
        $?.exitstatus
      rescue
        return 1
      end
    end
  end
end