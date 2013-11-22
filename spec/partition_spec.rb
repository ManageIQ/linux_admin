require 'spec_helper'

describe LinuxAdmin::Partition do
  before(:each) do
    @disk = LinuxAdmin::Disk.new :path => '/dev/sda'
    @partition = LinuxAdmin::Partition.new :disk => @disk, :id => 2
  end

  describe "#path" do
    it "returns partition path" do
      @partition.path.should == '/dev/sda2'
    end
  end

  describe "#mount" do
    context "mount_point not specified" do
      it "sets default mount_point" do
        described_class.should_receive(:mount_point_exists?).and_return(false)
        File.should_receive(:directory?).with('/mnt/sda2').and_return(true)
        @partition.should_receive(:run!)
        @partition.mount
        @partition.mount_point.should == '/mnt/sda2'
      end
    end
  end
end
