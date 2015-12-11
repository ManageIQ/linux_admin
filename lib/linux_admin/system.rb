module LinuxAdmin
  class System
    def self.reboot!
      Common.run!(Common.cmd(:shutdown),
          :params => { "-r" => "now" })
    end

    def self.shutdown!
      Common.run!(Common.cmd(:shutdown),
          :params => { "-h" => "0" })
    end
  end
end
