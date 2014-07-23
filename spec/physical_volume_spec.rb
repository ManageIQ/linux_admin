require 'spec_helper'

describe LinuxAdmin::PhysicalVolume do
  before(:each) do
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
      expect(pv).to receive(:run!).
         with(pv.cmd(:vgextend),
              :params => ['vg', '/dev/hda'])
      pv.attach_to(vg)
    end

    it "assigns volume group to physical volume" do
      vg = LinuxAdmin::VolumeGroup.new :name => 'vg'
      pv = described_class.new :device_name => '/dev/hda'
      allow(pv).to receive(:run!)
      pv.attach_to(vg)
      expect(pv.volume_group).to eq(vg)
    end

    it "returns self" do
      vg = LinuxAdmin::VolumeGroup.new :name => 'vg'
      pv = described_class.new :device_name => '/dev/hda'
      allow(pv).to receive(:run!)
      expect(pv.attach_to(vg)).to eq(pv)
    end
  end

  describe "#create" do
    before do
      @disk = LinuxAdmin::Disk.new :path => '/dev/hda'
      allow(@disk).to receive(:size)
    end

    let(:disk) {@disk}

    it "uses pvcreate" do
      described_class.instance_variable_set(:@pvs, [])
      expect(described_class).to receive(:run!).
                                 with(LinuxAdmin.cmd(:pvcreate),
                                      :params => { nil => '/dev/hda'})
      described_class.create disk
    end

    it "returns new physical volume" do
      LinuxAdmin::VolumeGroup.stub(:run! => double(:output => ""))
      described_class.stub(:run! => double(:output => ""))
      pv = described_class.create disk
      expect(pv).to be_an_instance_of(described_class)
      expect(pv.device_name).to eq('/dev/hda')
    end

    it "adds physical volume to local registry" do
      LinuxAdmin::VolumeGroup.stub(:run! => double(:output => ""))
      described_class.stub(:run! => double(:output => ""))
      pv = described_class.create disk
      expect(described_class.scan).to include(pv)
    end
  end

  describe "#scan" do
    it "uses pvdisplay" do
      expect(described_class).to receive(:run!).
                                 with(LinuxAdmin.cmd(:pvdisplay),
                                     :params => { '-c' => nil}).
                                 and_return(double(:output => @physical_volumes))
      expect(LinuxAdmin::VolumeGroup).to receive(:run!).and_return(double(:output => @groups)) # stub out call to vgdisplay
      described_class.scan
    end

    it "returns local physical volumes" do
      expect(described_class).to receive(:run!).and_return(double(:output => @physical_volumes))
      expect(LinuxAdmin::VolumeGroup).to receive(:run!).and_return(double(:output => @groups))
      pvs = described_class.scan

      expect(pvs[0]).to be_an_instance_of(described_class)
      expect(pvs[0].device_name).to eq('/dev/vda2')
      expect(pvs[0].size).to eq(24139776)
    end

    it "resolves volume group references" do
      expect(described_class).to receive(:run!).and_return(double(:output => @physical_volumes))
      expect(LinuxAdmin::VolumeGroup).to receive(:run!).and_return(double(:output => @groups))
      pvs = described_class.scan
      expect(pvs[0].volume_group).to be_an_instance_of(LinuxAdmin::VolumeGroup)
      expect(pvs[0].volume_group.name).to eq('vg_foobar')
    end
  end
end
