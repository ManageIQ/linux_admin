class TestMountable
  include LinuxAdmin::Mountable

  def path
    "/dev/foo"
  end
end

describe LinuxAdmin::Mountable do
  before(:each) do
    @mountable = TestMountable.new

    # stub out calls that modify system
    allow(FileUtils).to receive(:mkdir)
    allow(LinuxAdmin::Common).to receive(:run!)

    @mount_out1 = <<eos
/dev/sda on /mnt/usb type vfat (rw)
eos
    @mount_out2 = <<eos
cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,perf_event)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=26,pgrp=1,timeout=300,minproto=5,maxproto=5,direct)
eos

    @mount_out3 = <<eos
/dev/mapper/vg_data-lv_pg on /var/opt/rh/rh-postgresql95/lib/pgsql type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
/dev/foo on /tmp type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
/dev/foo on /home type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
eos
  end

  describe "#mount_point_exists?" do
    it "uses mount" do
      expect(LinuxAdmin::Common).to receive(:run!).with(LinuxAdmin::Common.cmd(:mount))
        .and_return(double(:output => ""))
      TestMountable.mount_point_exists?('/mnt/usb')
    end

    context "disk mounted at specified location" do
      before do
        expect(LinuxAdmin::Common).to receive(:run!).and_return(double(:output => @mount_out1))
      end

      it "returns true" do
        expect(TestMountable.mount_point_exists?('/mnt/usb')).to be_truthy
      end

      it "returns true when using a pathname" do
        path = Pathname.new("/mnt/usb")
        expect(TestMountable.mount_point_exists?(path)).to be_truthy
      end
    end

    context "no disk mounted at specified location" do
      before do
        expect(LinuxAdmin::Common).to receive(:run!).and_return(double(:output => @mount_out2))
      end

      it "returns false" do
        expect(TestMountable.mount_point_exists?('/mnt/usb')).to be_falsey
      end

      it "returns false when using a pathname" do
        path = Pathname.new("/mnt/usb")
        expect(TestMountable.mount_point_exists?(path)).to be_falsey
      end
    end
  end

  describe "#mount_point_available?" do
    it "uses mount" do
      expect(LinuxAdmin::Common).to receive(:run!).with(LinuxAdmin::Common.cmd(:mount))
        .and_return(double(:output => ""))
      TestMountable.mount_point_available?('/mnt/usb')
    end

    context "disk mounted at specified location" do
      before do
        expect(LinuxAdmin::Common).to receive(:run!).and_return(double(:output => @mount_out1))
      end

      it "returns false" do
        expect(TestMountable.mount_point_available?('/mnt/usb')).to be_falsey
      end

      it "returns false when using a pathname" do
        path = Pathname.new("/mnt/usb")
        expect(TestMountable.mount_point_available?(path)).to be_falsey
      end
    end

    context "no disk mounted at specified location" do
      before do
        expect(LinuxAdmin::Common).to receive(:run!).and_return(double(:output => @mount_out2))
      end

      it "returns true" do
        expect(TestMountable.mount_point_available?('/mnt/usb')).to be_truthy
      end

      it "returns true when using a pathname" do
        path = Pathname.new("/mnt/usb")
        expect(TestMountable.mount_point_available?(path)).to be_truthy
      end
    end
  end

  describe "#discover_mount_point" do
    it "sets the correct mountpoint when the path is mounted" do
      expect(LinuxAdmin::Common).to receive(:run!).and_return(double(:output => @mount_out3))
      @mountable.discover_mount_point
      expect(@mountable.mount_point).to eq("/tmp")
    end

    it "sets mount_point to nil when the path is not mounted" do
      expect(LinuxAdmin::Common).to receive(:run!).and_return(double(:output => @mount_out1))
      @mountable.discover_mount_point
      expect(@mountable.mount_point).to be_nil
    end
  end

  describe "#format_to" do
    it "uses mke2fs" do
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:mke2fs),
              :params => {'-t' => 'ext4', nil => '/dev/foo'})
      @mountable.format_to('ext4')
    end

    it "sets fs type" do
      expect(LinuxAdmin::Common).to receive(:run!) # ignore actual formatting cmd
      @mountable.format_to('ext4')
      expect(@mountable.fs_type).to eq('ext4')
    end
  end

  describe "#mount" do
    it "sets mount point" do
      # ignore actual mount cmds
      expect(LinuxAdmin::Common).to receive(:run!).and_return(double(:output => ""))
      expect(LinuxAdmin::Common).to receive(:run!).and_return(double(:output => ""))

      expect(@mountable.mount('/mnt/sda2')).to eq('/mnt/sda2')
      expect(@mountable.mount_point).to eq('/mnt/sda2')
    end

    context "mountpoint does not exist" do
      it "creates mountpoint" do
        expect(TestMountable).to receive(:mount_point_exists?).and_return(false)
        expect(File).to receive(:directory?).with('/mnt/sda2').and_return(false)
        expect(FileUtils).to receive(:mkdir).with('/mnt/sda2')
        expect(LinuxAdmin::Common).to receive(:run!) # ignore actual mount cmd
        @mountable.mount '/mnt/sda2'
      end
    end

    context "disk mounted at mountpoint" do
      it "raises argument error" do
        expect(TestMountable).to receive(:mount_point_exists?).and_return(true)
        expect(File).to receive(:directory?).with('/mnt/sda2').and_return(true)
        expect { @mountable.mount '/mnt/sda2' }.to raise_error(ArgumentError, "disk already mounted at /mnt/sda2")
      end
    end

    it "mounts partition" do
      expect(TestMountable).to receive(:mount_point_exists?).and_return(false)
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:mount),
              :params => {nil => ['/dev/foo', '/mnt/sda2']})
      @mountable.mount '/mnt/sda2'
    end
  end

  describe "#umount" do
    it "unmounts partition" do
      @mountable.mount_point = '/mnt/sda2'
      expect(LinuxAdmin::Common).to receive(:run!).with(LinuxAdmin::Common.cmd(:umount),
                                                        :params => {nil => ['/mnt/sda2']})
      @mountable.umount
    end
  end
end
