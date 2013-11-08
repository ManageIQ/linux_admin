# LinuxAdmin Abstract Package Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

class LinuxAdmin
  class Package < LinuxAdmin
    def self.info(pkg)
      if Distro.local == Distros.redhat
        return Rpm.info(pkg)
      elsif Distro.local == Distros.ubuntu
        return Deb.info(pkg)
      end

      nil
    end
  end
end
