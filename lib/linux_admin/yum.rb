module LinuxAdmin
  module Yum
    def self.updates_available?
      case Common.run("yum check-update")
      when 0;   false
      when 100; true
      else raise "Error: Exit Code #{status}"
      end
    end

    def self.update
      case Common.run("yum -y update")
      when 0; true
      else raise "Error: Exit Code #{status}"
      end
    end
  end
end