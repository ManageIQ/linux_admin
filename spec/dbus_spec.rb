require 'spec_helper'

describe LinuxAdmin::DBus do
  describe "#bus" do
    it "returns dbus system bus"
  end

  describe "#service" do
    it "returns service on dbus system bus"
  end
end

describe LinuxAdmin::DBusService do
  describe "#object" do
    it "returns dbus object on service bus"
  end
end

describe LinuxAdmin::DBusObject do
  describe "#interface" do
    it "returns dbus interface to object"
  end
end

describe LinuxAdmin::DBusInterface do
  describe "#[]" do
    it "dispatches to dbus interface"
  end

  describe "#[]=" do
    it "dispatches to dbus interface"
  end
end
