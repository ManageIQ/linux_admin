require 'spec_helper'
require 'stringio'

describe LinuxAdmin::FSTab do
  before do
    # Reset the singleton so subsequent tests get a new instance
    Singleton.send :__init__, LinuxAdmin::FSTab
  end

  it "has newline, single spaces, tab" do
    fstab = <<eos

  
	
eos
    File.should_receive(:read).with('/etc/fstab').and_return(fstab)
    LinuxAdmin::FSTab.instance.entries.size.should == 3
    LinuxAdmin::FSTab.instance.entries.any? { |e| e.has_content? }.should be_false
  end

  it "creates FSTabEntry for each line in fstab" do
    fstab = <<eos
# Comment, indented comment, comment with device information
  # /dev/sda1 / ext4  defaults  1 1
# /dev/sda1 / ext4  defaults  1 1

/dev/sda1 / ext4  defaults  1 1
/dev/sda2 swap  swap  defaults  0 0
eos
    File.should_receive(:read).with('/etc/fstab').and_return(fstab)
    entries = LinuxAdmin::FSTab.instance.entries
    entries.size.should == 6

    entries[0].comment.should == "# Comment, indented comment, comment with device information\n"
    entries[1].comment.should == "# /dev/sda1 / ext4  defaults  1 1\n"
    entries[2].comment.should == "# /dev/sda1 / ext4  defaults  1 1\n"
    entries[3].comment.should == nil
    entries[4].device.should == '/dev/sda1'
    entries[4].mount_point.should == '/'
    entries[4].fs_type.should == 'ext4'
    entries[4].mount_options.should == 'defaults'
    entries[4].dumpable.should == 1
    entries[4].fsck_order.should == 1

    entries[5].device.should == '/dev/sda2'
    entries[5].mount_point.should == 'swap'
    entries[5].fs_type.should == 'swap'
    entries[5].mount_options.should == 'defaults'
    entries[5].dumpable.should == 0
    entries[5].fsck_order.should == 0
  end

  describe "#write!" do
    it "writes entries to /etc/fstab" do
      # maually set fstab
      entry = LinuxAdmin::FSTabEntry.new
      entry.device        = '/dev/sda1'
      entry.mount_point   = '/'
      entry.fs_type       = 'ext4'
      entry.mount_options = 'defaults'
      entry.dumpable      = 1
      entry.fsck_order    = 1
      entry.comment = "# more"
      LinuxAdmin::FSTab.any_instance.stub(:refresh) # don't read /etc/fstab
      LinuxAdmin::FSTab.instance.maximum_column_lengths = [9, 1, 4, 8, 1, 1, 1]
      LinuxAdmin::FSTab.instance.entries  = [entry]

      File.should_receive(:write).with('/etc/fstab', "/dev/sda1 / ext4 defaults 1 1 # more\n")
      LinuxAdmin::FSTab.instance.write!
    end
  end
end
