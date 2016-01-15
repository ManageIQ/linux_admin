module LinuxAdmin
  class Hardware
    def total_cores
      File.readlines("/proc/cpuinfo").count { |line| line =~ /^processor\s+:\s+\d+/ }
    end
  end
end
