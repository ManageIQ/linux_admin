require 'spec_helper'

describe LinuxAdmin::Partition do
  before(:each) do
    @disk = LinuxAdmin::Disk.new :path => '/dev/sda'
    @partition = LinuxAdmin::Partition.new :disk => @disk, :id => 2
  end

  describe "#path" do
    it "returns partition path" do
      expect(@partition.path).to eq('/dev/sda2')
    end
  end

  describe "#mount" do
    context "mount_point not specified" do
      it "sets default mount_point" do
        expect(described_class).to receive(:mount_point_exists?).and_return(false)
        expect(File).to receive(:directory?).with('/mnt/sda2').and_return(true)
        expect(@partition).to receive(:run!)
        @partition.mount
        expect(@partition.mount_point).to eq('/mnt/sda2')
      end
    end
  end
end
