require 'spec_helper'

describe LinuxAdmin::Disk do
  describe "#local" do
    it "returns local disks" do
      Dir.should_receive(:glob).with('/dev/[vhs]d[a-z]').
          and_return(['/dev/hda', '/dev/sda'])
      disks = LinuxAdmin::Disk.local
      paths = disks.collect { |disk| disk.path }
      paths.should include('/dev/hda')
      paths.should include('/dev/sda')
    end
  end

  describe "#partitions" do
    it "uses parted" do
      disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      disk.should_receive(:run).
        with(disk.cmd(:parted),
             :return_exitstatus => true,
             :return_output => true,
             :params => { nil => ['/dev/hda', 'print'] }).and_return ""
      disk.partitions
    end

    it "returns [] on non-zero parted rc" do
      disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      disk.stub(:exitstatus => 1)
      disk.stub(:launch)
      disk.partitions.should == []
    end

    it "sets partitons" do
      partitions = <<eos
Model: ATA TOSHIBA MK5061GS (scsi)
Disk /dev/sda: 500GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type      File system     Flags
 1      1259MB  81.8GB  80.5GB  primary   ntfs
 2      81.8GB  162GB   80.5GB  primary   ext4
 3      162GB   163GB   1074MB  logical   linux-swap(v1)
eos
      disk = LinuxAdmin::Disk.new
      disk.should_receive(:run).and_return(partitions)

      disk.partitions[0].id.should == 1
      disk.partitions[0].disk.should == disk
      disk.partitions[0].size.should == 80.5.gigabytes
      disk.partitions[0].fs_type.should == 'ntfs'
      disk.partitions[1].id.should == 2
      disk.partitions[1].disk.should == disk
      disk.partitions[1].size.should == 80.5.gigabytes
      disk.partitions[1].fs_type.should == 'ext4'
      disk.partitions[2].id.should == 3
      disk.partitions[2].disk.should == disk
      disk.partitions[2].size.should == 1074.megabytes
      disk.partitions[2].fs_type.should == 'linux-swap(v1)'
    end
  end
end
