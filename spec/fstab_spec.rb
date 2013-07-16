require 'spec_helper'
require 'stringio'

describe LinuxAdmin::FSTab do
  it "creates FSTabEntry for each line in fstab" do
    fstab = <<eos
/dev/sda1 / ext4  defaults  1 1
/dev/sda2 swap  swap  defaults  0 0
eos
    File.should_receive(:read).with('/etc/fstab').and_return(fstab)
    entries = LinuxAdmin::FSTab.instance.entries
    entries.size.should == 2

    entries[0].device.should == '/dev/sda1'
    entries[0].mount_point.should == '/'
    entries[0].fs_type.should == 'ext4'
    entries[0].mount_options.should == 'defaults'
    entries[0].dumpable.should == 1
    entries[0].fsck_order.should == 1

    entries[1].device.should == '/dev/sda2'
    entries[1].mount_point.should == 'swap'
    entries[1].fs_type.should == 'swap'
    entries[1].mount_options.should == 'defaults'
    entries[1].dumpable.should == 0
    entries[1].fsck_order.should == 0
  end

  describe "#write" do
    it "writes entries to /etc/fstab" do
      # maually set fstab
      entry = LinuxAdmin::FSTabEntry.new
      entry.device        = '/dev/sda1'
      entry.mount_point   = '/'
      entry.fs_type       = 'ext4'
      entry.mount_options = 'defaults'
      entry.dumpable      = 1
      entry.fsck_order    = 1
      LinuxAdmin::FSTab.instance.entries = [entry]

      f = StringIO.new
      File.should_receive(:open).with('/etc/fstab', 'w').and_return(f)
      LinuxAdmin::FSTab.instance.write
      f.string.should == "/dev/sda1 / ext4 defaults 1 1\n"
    end
  end
end
