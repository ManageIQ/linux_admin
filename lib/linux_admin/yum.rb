module LinuxAdmin
  module Yum
    def self.check  # Will return 100 when updates are available.
      Common.run("yum check-update")
    end

    def self.update
      Common.run("yum -y update")
    end
  end
end