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

  describe "#size" do
    it "uses fdisk" do
      disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      disk.should_receive(:run!).
        with(disk.cmd(:fdisk),
             :params => {"-l" => nil}).
        and_return(double(:output => ""))
      disk.size
    end

    it "returns disk size" do
      fdisk = <<eos
Disk /dev/hda: 500.1 GB, 500107862016 bytes
255 heads, 63 sectors/track, 60801 cylinders, total 976773168 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x3ddb508b

   Device Boot      Start         End      Blocks   Id  System
 1      1259MB  81.8GB  80.5GB  primary   ntfs
 2      81.8GB  162GB   80.5GB  primary   ext4
 3      162GB   163GB   1074MB  logical   linux-swap(v1)
eos

      disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      disk.stub(:run!).and_return(double(:output => fdisk))
      disk.size.should == 500.1.gigabytes
    end
  end

  describe "#partitions" do
    it "uses parted" do
      disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      disk.should_receive(:run).
        with(disk.cmd(:parted),
             :params => { nil => ['/dev/hda', 'print'] }).and_return(double(:output => ""))
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
      disk.should_receive(:run).and_return(double(:output => partitions))

      disk.partitions[0].id.should == 1
      disk.partitions[0].disk.should == disk
      disk.partitions[0].size.should == 80.5.gigabytes
      disk.partitions[0].start_sector.should == 1259.megabytes
      disk.partitions[0].end_sector.should == 81.8.gigabytes
      disk.partitions[0].partition_type.should == 'primary'
      disk.partitions[0].fs_type.should == 'ntfs'
      disk.partitions[1].id.should == 2
      disk.partitions[1].disk.should == disk
      disk.partitions[1].size.should == 80.5.gigabytes
      disk.partitions[1].start_sector.should == 81.8.gigabytes
      disk.partitions[1].end_sector.should == 162.gigabytes
      disk.partitions[1].partition_type.should == 'primary'
      disk.partitions[1].fs_type.should == 'ext4'
      disk.partitions[2].id.should == 3
      disk.partitions[2].disk.should == disk
      disk.partitions[2].size.should == 1074.megabytes
      disk.partitions[2].start_sector.should == 162.gigabytes
      disk.partitions[2].end_sector.should == 163.gigabytes
      disk.partitions[2].partition_type.should == 'logical'
      disk.partitions[2].fs_type.should == 'linux-swap(v1)'
    end
  end

  describe "#create_partition" do
    before(:each) do
      # test disk w/ existing partition
      @disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      @disk.instance_variable_set(:@partitions,
                                  [LinuxAdmin::Partition.new(:id => 1,
                                                 :end_sector => 1024)])
      @disk.stub(:has_partition_table? => true)
    end

    it "uses parted" do
      @disk.should_receive(:run!).
        with(@disk.cmd(:parted),
             :params => { nil => ['/dev/hda', 'mkpart', 'primary', 1024, 2048] })
      @disk.create_partition 'primary', 1024
    end

    it "returns partition" do
      @disk.should_receive(:run!) # stub out call to parted
      partition = @disk.create_partition 'primary', 1024
      partition.should be_an_instance_of(LinuxAdmin::Partition)
    end

    it "increments partition id" do
      @disk.should_receive(:run!) # stub out call to parted
      partition = @disk.create_partition 'primary', 1024
      partition.id.should == 2
    end

    it "sets partition start to first unused sector on disk" do
      @disk.should_receive(:run!) # stub out call to parted
      partition = @disk.create_partition 'primary', 1024
      partition.start_sector.should == 1024
    end

    it "stores new partition locally" do
      @disk.should_receive(:run!) # stub out call to parted
      lambda {
        @disk.create_partition 'primary', 1024
      }.should change{@disk.partitions.size}.by(1)
    end

    it "creates partition table if missing" do
      @disk.stub(:has_partition_table? => false)
      @disk.should_receive(:create_partition_table)
      @disk.should_receive(:run!)
      @disk.create_partition 'primary', 1024
    end
  end

  describe "#has_partition_table?" do
    it "positive case" do
      disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      disk.should_receive(:run).and_return(double(:output => "", :exit_status => 0))
      disk.should have_partition_table
    end

    it "negative case" do
      disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      output = "\e[?1034h\r\rError: /dev/sdb: unrecognised disk label\n"
      disk.should_receive(:run).and_return(double(:output => output, :exit_status => 1))
      disk.should_not have_partition_table
    end
  end

  it "#create_partition_table" do
    disk = LinuxAdmin::Disk.new :path => '/dev/hda'
    options = {:params => {nil => ["/dev/hda", "mklabel", "msdos"]}}
    disk.should_receive(:run!).with(disk.cmd(:parted), options)
    disk.create_partition_table
  end

  describe "#clear!" do
    it "clears partitions" do
      disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      disk.should_receive(:run).and_return(double(:output => "")) # stub out call to cmds
      disk.partitions << LinuxAdmin::Partition.new

      disk.should_receive(:run!)
      disk.clear!
      disk.partitions.should be_empty
    end

    it "uses dd to clear partition table" do
      disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      disk.should_receive(:run!).
           with(disk.cmd(:dd),
                :params => {'if=' => '/dev/zero', 'of=' => '/dev/hda',
                            'bs=' => 512, 'count=' => 1})
      disk.clear!
    end

    it "returns self" do
      disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      disk.stub(:run!) # stub out call to dd
      disk.clear!.should == disk
    end
  end

end
