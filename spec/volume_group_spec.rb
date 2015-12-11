describe LinuxAdmin::VolumeGroup do
  before(:each) do
    @groups = <<eos
  vg_foobar:r/w:772:-1:0:2:2:-1:0:1:1:12058624:32768:368:368:0:tILZUF-IspH-H90I-pT5j-vVFl-b76L-zWx3CW
eos
  end

  after(:each) do
    # reset local copies of volumes / groups
    LinuxAdmin::LogicalVolume.instance_variable_set(:@lvs, nil)
    LinuxAdmin::PhysicalVolume.instance_variable_set(:@pvs, nil)
    described_class.instance_variable_set(:@vgs, nil)
  end

  describe "#attach_to" do
    it "uses lvextend" do
      vg = described_class.new :name => 'vg'
      lv = LinuxAdmin::LogicalVolume.new :name => 'lv', :volume_group => vg
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:lvextend), :params => %w(lv vg))
      vg.attach_to(lv)
    end

    it "returns self" do
      vg = described_class.new :name => 'vg'
      lv = LinuxAdmin::LogicalVolume.new :name => 'lv', :volume_group => vg
      allow(LinuxAdmin::Common).to receive(:run!)
      expect(vg.attach_to(lv)).to eq(vg)
    end
  end

  describe "#extend_with" do
    it "uses vgextend" do
      vg = described_class.new :name => 'vg'
      pv = LinuxAdmin::PhysicalVolume.new :device_name => '/dev/hda'
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:vgextend), :params => ['vg', '/dev/hda'])
      vg.extend_with(pv)
    end

    it "assigns volume group to physical volume" do
      vg = described_class.new :name => 'vg'
      pv = LinuxAdmin::PhysicalVolume.new :device_name => '/dev/hda'
      allow(LinuxAdmin::Common).to receive(:run!)
      vg.extend_with(pv)
      expect(pv.volume_group).to eq(vg)
    end

    it "returns self" do
      vg = described_class.new :name => 'vg'
      pv = LinuxAdmin::PhysicalVolume.new :device_name => '/dev/hda'
      allow(LinuxAdmin::Common).to receive(:run!)
      expect(vg.extend_with(pv)).to eq(vg)
    end
  end

  describe "#create" do
    before(:each) do
      @pv = LinuxAdmin::PhysicalVolume.new :device_name => '/dev/hda'
    end

    it "uses vgcreate" do
      described_class.instance_variable_set(:@vgs, [])
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:vgcreate), :params => ['vg', '/dev/hda'])
      described_class.create 'vg', @pv
    end

    it "returns new volume group" do
      allow(LinuxAdmin::Common).to receive_messages(:run! => double(:output => ""))
      vg = described_class.create 'vg', @pv
      expect(vg).to be_an_instance_of(described_class)
      expect(vg.name).to eq('vg')
    end

    it "adds volume group to local registry" do
      allow(LinuxAdmin::Common).to receive_messages(:run! => double(:output => ""))
      vg = described_class.create 'vg', @pv
      expect(described_class.scan).to include(vg)
    end
  end

  describe "#scan" do
    it "uses vgdisplay" do
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:vgdisplay), :params => {'-c' => nil})
        .and_return(double(:output => @groups))
      described_class.scan
    end

    it "returns local volume groups" do
      expect(LinuxAdmin::Common).to receive(:run!).and_return(double(:output => @groups))
      vgs = described_class.scan

      expect(vgs[0]).to be_an_instance_of(described_class)
      expect(vgs[0].name).to eq('vg_foobar')
    end
  end
end
