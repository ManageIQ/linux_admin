# LinuxAdmin System Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

class LinuxAdmin
  class System < LinuxAdmin
    def self.reboot!
      run!(cmd(:shutdown),
          :params => { "-r" => "now" })
    end

    def self.shutdown!
      run!(cmd(:shutdown),
          :params => { "-h" => "0" })
    end
  end
end
