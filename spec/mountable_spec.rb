require 'spec_helper'

class TestMountable < LinuxAdmin
  include LinuxAdmin::Mountable

  def path
    "/dev/foo"
  end
end

describe LinuxAdmin::Mountable do
  before(:each) do
    @mountable = TestMountable.new

    # stub out calls that modify system
    FileUtils.stub(:mkdir)
    @mountable.stub(:run!)

    @mount_out1 = <<eos
/dev/sda on /mnt/usb type vfat (rw)
eos
    @mount_out2 = <<eos
cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,perf_event)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=26,pgrp=1,timeout=300,minproto=5,maxproto=5,direct)
eos
  end

  describe "#mount_point_exists?" do
    it "uses mount" do
      TestMountable.should_receive(:run!).with(TestMountable.cmd(:mount)).and_return(CommandResult.new("", "", "", 0))
      TestMountable.mount_point_exists?('/mnt/usb')
    end

    context "disk mounted at specified location" do
      it "returns true" do
        TestMountable.should_receive(:run!).and_return(CommandResult.new("", @mount_out1, "", 0))
        TestMountable.mount_point_exists?('/mnt/usb').should be_true
      end
    end

    context "no disk mounted at specified location" do
      it "returns false" do
        TestMountable.should_receive(:run!).and_return(CommandResult.new("", @mount_out2, "", 0))
        TestMountable.mount_point_exists?('/mnt/usb').should be_false
      end
    end
  end

  describe "#mount_point_available?" do
    it "uses mount" do
      TestMountable.should_receive(:run!).with(TestMountable.cmd(:mount)).and_return(CommandResult.new("", "", "", 0))
      TestMountable.mount_point_available?('/mnt/usb')
    end

    context "disk mounted at specified location" do
      it "returns false" do
        TestMountable.should_receive(:run!).and_return(CommandResult.new("", @mount_out1, "", 0))
        TestMountable.mount_point_available?('/mnt/usb').should be_false
      end
    end

    context "no disk mounted at specified location" do
      it "returns true" do
        TestMountable.should_receive(:run!).and_return(CommandResult.new("", @mount_out2, "", 0))
        TestMountable.mount_point_available?('/mnt/usb').should be_true
      end
    end
  end

  describe "#format_to" do
    it "uses mke2fs" do
      @mountable.should_receive(:run!).
         with(@mountable.cmd(:mke2fs),
              :params => { '-t' => 'ext4', nil => '/dev/foo'})
      @mountable.format_to('ext4')
    end

    it "sets fs type" do
      @mountable.should_receive(:run!) # ignore actual formatting cmd
      @mountable.format_to('ext4')
      @mountable.fs_type.should == 'ext4'
    end
  end

  describe "#mount" do
    it "sets mount point" do
      # ignore actual mount cmds
      @mountable.should_receive(:run!).and_return(CommandResult.new("", "", "", ""))
      TestMountable.should_receive(:run!).and_return(CommandResult.new("", "", "", ""))

      @mountable.mount('/mnt/sda2').should == '/mnt/sda2'
      @mountable.mount_point.should == '/mnt/sda2'
    end
    
    context "mountpoint does not exist" do
      it "creates mountpoint" do
        TestMountable.should_receive(:mount_point_exists?).and_return(false)
        File.should_receive(:directory?).with('/mnt/sda2').and_return(false)
        FileUtils.should_receive(:mkdir).with('/mnt/sda2')
        @mountable.should_receive(:run!) # ignore actual mount cmd
        @mountable.mount '/mnt/sda2'
      end
    end

    context "disk mounted at mountpoint" do
      it "raises argument error" do
        TestMountable.should_receive(:mount_point_exists?).and_return(true)
        File.should_receive(:directory?).with('/mnt/sda2').and_return(true)
        expect { @mountable.mount '/mnt/sda2' }.to raise_error(ArgumentError, "disk already mounted at /mnt/sda2")
      end
    end

    it "mounts partition" do
      TestMountable.should_receive(:mount_point_exists?).and_return(false)
      @mountable.should_receive(:run!).
         with(@mountable.cmd(:mount),
              :params => { nil => ['/dev/foo', '/mnt/sda2']})
      @mountable.mount '/mnt/sda2'
    end
  end

  describe "#umount" do
    it "unmounts partition" do
      @mountable.mount_point = '/mnt/sda2'
      @mountable.should_receive(:run!).with(@mountable.cmd(:umount), :params => { nil => ['/mnt/sda2']})
      @mountable.umount
    end
  end

end
