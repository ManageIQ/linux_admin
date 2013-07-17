# LinuxAdmin DBus Interface
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

require "dbus"

# example usage
# s = LinuxAdmin::DBus.service "org.freedesktop.NetworkManager"
# o = s.object '/org/freedesktop/NetworkManager'
# i = o.interface
# puts i['WirelessEnabled']
# i['WirelessEnabled'] = false
#
class LinuxAdmin
  class DBus < LinuxAdmin
    def self.bus
      ::DBus::SystemBus.instance
    end

    def self.service(id)
      DBusService.new :id => id,
                      :dbus_service => bus[id]
    end
  end

  class DBusService
    attr_accessor :id
    attr_accessor :dbus_service

    def initialize(args = {})
      @id           = args[:id]
      @dbus_service = args[:dbus_service]
    end

    def object(path)
      DBusObject.new :dbus_object => @dbus_service.object(path),
                     :service     => self
    end

  end

  class DBusObject
    attr_accessor :dbus_object
    attr_accessor :service

    def initialize(args = {})
      @dbus_object = args[:dbus_object]
      @service     = args[:service]
      @dbus_object.introspect
    end

    def interface(id=nil)
      id = service.id if id.nil?
      DBusInterface.new :dbus_interface => @dbus_object[id],
                        :object => self
    end
  end

  class DBusInterface
    attr_accessor :dbus_interface
    attr_accessor :object

    def initialize(args = {})
      @dbus_interface = args[:dbus_interface]
      @object         = args[:object]
    end

    # dispatch Get, [], []=, devices to to the interface
    def get(i, v)
      @dbus_interface.Get(i, v)
    end

    def [](i)
      @dbus_interface[i]
    end

    def []=(i,v)
      @dbus_interface[i] = v
    end

    def devices(interface = nil)
      @dbus_interface.GetDevices.first.collect { |d|
        o =  object.service.object d
        interface.nil? ? o : o.interface(interface)
      }
    end
  end
end
