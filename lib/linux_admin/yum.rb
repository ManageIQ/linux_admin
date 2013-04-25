module LinuxAdmin
  module Yum
    def self.updates_available?
      exitstatus = Common.run("yum check-update", :return_exitstatus => true)
      case exitstatus
      when 0;   false
      when 100; true
      else raise "Error: Exit Code #{exitstatus}"
      end
    end

    def self.update
      Common.run("yum -y update")
    end
  end
end