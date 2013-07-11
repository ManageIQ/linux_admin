require 'spec_helper'

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
end
