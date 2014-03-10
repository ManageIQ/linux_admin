require 'spec_helper'

describe LinuxAdmin::PhysicalVolume do
  before(:each) do
    LinuxAdmin::Distros::Distro.stub(:local => LinuxAdmin::Distros::Test.new)

    @physical_volumes = <<eos
  /dev/vda2:vg_foobar:24139776:-1:8:8:-1:32768:368:0:368:pxR32D-YkC2-PfHe-zOwb-eaGD-9Ar0-mAOl9u
eos

    @groups = <<eos
  vg_foobar:r/w:772:-1:0:2:2:-1:0:1:1:12058624:32768:368:368:0:tILZUF-IspH-H90I-pT5j-vVFl-b76L-zWx3CW
eos
  end

  after(:each) do
    # reset local copies of volumes / groups
    LinuxAdmin::LogicalVolume.instance_variable_set(:@lvs, nil)
    described_class.instance_variable_set(:@pvs, nil)
    LinuxAdmin::VolumeGroup.instance_variable_set(:@vgs, nil)
  end

  describe "#attach_to" do
    it "uses vgextend" do
      vg = LinuxAdmin::VolumeGroup.new :name => 'vg'
      pv = described_class.new :device_name => '/dev/hda'
      pv.should_receive(:run!).
         with(pv.cmd(:vgextend),
              :params => ['vg', '/dev/hda'])
      pv.attach_to(vg)
    end

    it "assigns volume group to physical volume" do
      vg = LinuxAdmin::VolumeGroup.new :name => 'vg'
      pv = described_class.new :device_name => '/dev/hda'
      pv.stub(:run!)
      pv.attach_to(vg)
      pv.volume_group.should == vg
    end

    it "returns self" do
      vg = LinuxAdmin::VolumeGroup.new :name => 'vg'
      pv = described_class.new :device_name => '/dev/hda'
      pv.stub(:run!)
      pv.attach_to(vg).should == pv
    end
  end

  describe "#create" do
    before do
      @disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      @disk.stub(:size)
    end

    let(:disk) {@disk}

    it "uses pvcreate" do
      described_class.instance_variable_set(:@pvs, [])
      described_class.should_receive(:run!).
                                 with(LinuxAdmin.cmd(:pvcreate),
                                      :params => { nil => '/dev/hda'})
      described_class.create disk
    end

    it "returns new physical volume" do
      LinuxAdmin::VolumeGroup.stub(:run! => double(:output => ""))
      described_class.stub(:run! => double(:output => ""))
      pv = described_class.create disk
      pv.should be_an_instance_of(described_class)
      pv.device_name.should == '/dev/hda'
    end

    it "adds physical volume to local registry" do
      LinuxAdmin::VolumeGroup.stub(:run! => double(:output => ""))
      described_class.stub(:run! => double(:output => ""))
      pv = described_class.create disk
      described_class.scan.should include(pv)
    end
  end

  describe "#scan" do
    it "uses pvdisplay" do
      described_class.should_receive(:run!).
                                 with(LinuxAdmin.cmd(:pvdisplay),
                                     :params => { '-c' => nil}).
                                 and_return(double(:output => @physical_volumes))
      LinuxAdmin::VolumeGroup.should_receive(:run!).and_return(double(:output => @groups)) # stub out call to vgdisplay
      described_class.scan
    end

    it "returns local physical volumes" do
      described_class.should_receive(:run!).and_return(double(:output => @physical_volumes))
      LinuxAdmin::VolumeGroup.should_receive(:run!).and_return(double(:output => @groups))
      pvs = described_class.scan

      pvs[0].should be_an_instance_of(described_class)
      pvs[0].device_name.should == '/dev/vda2'
      pvs[0].size.should == 24139776
    end

    it "resolves volume group references" do
      described_class.should_receive(:run!).and_return(double(:output => @physical_volumes))
      LinuxAdmin::VolumeGroup.should_receive(:run!).and_return(double(:output => @groups))
      pvs = described_class.scan
      pvs[0].volume_group.should be_an_instance_of(LinuxAdmin::VolumeGroup)
      pvs[0].volume_group.name.should == 'vg_foobar'
    end
  end
end
