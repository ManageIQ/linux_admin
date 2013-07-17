# LinuxAdmin NIC Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

require 'linux_admin/dbus'

def inet_ntoa(n)
  [n].pack("N").unpack("C*").reverse.join "."
end

class LinuxAdmin
  class NIC < LinuxAdmin
    attr_accessor :address

    def initialize(args = {})
      @address = args[:address]
    end

    def self.local
      s = LinuxAdmin::DBus.service "org.freedesktop.NetworkManager"
      o = s.object '/org/freedesktop/NetworkManager'
      i = o.interface
      i.devices().collect do |d|
        p = d.interface("org.freedesktop.DBus.Properties")
        address = inet_ntoa p.get('org.freedesktop.NetworkManager.Device', 'Ip4Address').last
        NIC.new :address => address
      end
    end
  end
end
