require 'spec_helper'

describe LinuxAdmin::Partition do
  before(:each) do
    @disk = LinuxAdmin::Disk.new :path => '/dev/sda'
    @partition = LinuxAdmin::Partition.new :disk => @disk, :id => 2

    # stub out calls that modify system
    FileUtils.stub(:mkdir)
    @partition.stub(:run)
  end

  describe "#path" do
    it "returns partition path" do
      @partition.path.should == '/dev/sda2'
    end
  end

  describe "#mount" do
    it "sets mount point" do
      @partition.should_receive(:run) # ignore actual mount cmd
      @partition.mount
      @partition.mount_point.should == '/mnt/sda2'
    end

    context "mountpoint does not exist" do
      it "creates mountpoint" do
        File.should_receive(:directory?).with('/mnt/sda2').and_return(false)
        FileUtils.should_receive(:mkdir).with('/mnt/sda2')
        @partition.should_receive(:run) # ignore actual mount cmd
        @partition.mount
      end
    end

    it "mounts partition" do
      @partition.should_receive(:run).
         with(@partition.cmd(:mount),
              :params => { nil => ['/dev/sda2', '/mnt/sda2']})
      @partition.mount
    end
  end

  describe "#umount" do
    it "unmounts partition" do
      @partition.mount_point = '/mnt/sda2'
      @partition.should_receive(:run).
         with(@partition.cmd(:umount),
              :params => { nil => ['/mnt/sda2']})
      @partition.umount
    end
  end
end
