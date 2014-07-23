require 'spec_helper'

describe LinuxAdmin::LogicalVolume do
  before(:each) do
    @logical_volumes = <<eos
  /dev/vg_foobar/lv_swap:vg_foobar:3:1:-1:2:4128768:63:-1:0:-1:253:0
  /dev/vg_foobar/lv_root:vg_foobar:3:1:-1:1:19988480:305:-1:0:-1:253:1
eos

    @groups = <<eos
  vg_foobar:r/w:772:-1:0:2:2:-1:0:1:1:12058624:32768:368:368:0:tILZUF-IspH-H90I-pT5j-vVFl-b76L-zWx3CW
eos
  end

  after(:each) do
    # reset local copies of volumes / groups
    described_class.instance_variable_set(:@lvs, nil)
    LinuxAdmin::PhysicalVolume.instance_variable_set(:@pvs, nil)
    LinuxAdmin::VolumeGroup.instance_variable_set(:@vgs, nil)
  end

  describe "#extend_with" do
    it "uses lvextend" do
      vg = LinuxAdmin::VolumeGroup.new :name => 'vg'
      lv = described_class.new :name => 'lv', :volume_group => vg
      expect(lv).to receive(:run!).
         with(vg.cmd(:lvextend),
              :params => ['lv', 'vg'])
      lv.extend_with(vg)
    end

    it "returns self" do
      vg = LinuxAdmin::VolumeGroup.new :name => 'vg'
      lv = described_class.new :name => 'lv', :volume_group => vg
      allow(lv).to receive(:run!)
      expect(lv.extend_with(vg)).to eq(lv)
    end
  end

  describe "#path" do
    it "returns /dev/vgname/lvname" do
      vg = LinuxAdmin::VolumeGroup.new :name => 'vg'
      lv = described_class.new :name => 'lv', :volume_group => vg
      expect(lv.path).to eq('/dev/vg/lv')
    end
  end

  describe "#create" do
    before(:each) do
      @vg = LinuxAdmin::VolumeGroup.new :name => 'vg'
    end

    it "uses lvcreate" do
      described_class.instance_variable_set(:@lvs, [])
      expect(described_class).to receive(:run!).
                                with(LinuxAdmin.cmd(:lvcreate),
                                     :params => { '-n' => 'lv',
                                                   nil => 'vg',
                                                  '-L' => '256G' })
      described_class.create 'lv', @vg, 256.gigabytes
    end

    context "size is specified" do
      it "passes -L option to lvcreate" do
        described_class.instance_variable_set(:@lvs, [])
        expect(described_class).to receive(:run!).
                                  with(LinuxAdmin.cmd(:lvcreate),
                                       :params => { '-n' => 'lv',
                                                     nil => 'vg',
                                                    '-L' => '256G' })
        described_class.create 'lv', @vg, 256.gigabytes
      end
    end

    context "extents is specified" do
      it "passes -l option to lvcreate" do
        described_class.instance_variable_set(:@lvs, [])
        expect(described_class).to receive(:run!).
                                  with(LinuxAdmin.cmd(:lvcreate),
                                       :params => { '-n' => 'lv',
                                                     nil => 'vg',
                                                    '-l' => '100%FREE' })
        described_class.create 'lv', @vg, 100
      end
    end

    it "returns new logical volume" do
      allow(LinuxAdmin::VolumeGroup).to receive_messages(:run! => double(:output => ""))
      allow(described_class).to receive_messages(:run! => double(:output => ""))
      lv = described_class.create 'lv', @vg, 256.gigabytes
      expect(lv).to be_an_instance_of(described_class)
      expect(lv.name).to eq('lv')
    end

    context "name is specified" do
      it "sets path under volume group" do
        allow(LinuxAdmin::VolumeGroup).to receive_messages(:run! => double(:output => ""))
        allow(described_class).to receive_messages(:run! => double(:output => ""))
        lv = described_class.create 'lv', @vg, 256.gigabytes
        expect(lv.path.to_s).to eq("#{described_class::DEVICE_PATH}#{@vg.name}/lv")
      end
    end

    context "path is specified" do
      it "sets name" do
        allow(LinuxAdmin::VolumeGroup).to receive_messages(:run! => double(:output => ""))
        allow(described_class).to receive_messages(:run! => double(:output => ""))
        lv = described_class.create '/dev/lv', @vg, 256.gigabytes
        expect(lv.name).to eq("lv")
      end
    end

    context "path is specified as Pathname" do
      it "sets name" do
        require 'pathname'
        allow(LinuxAdmin::VolumeGroup).to receive_messages(:run! => double(:output => ""))
        allow(described_class).to receive_messages(:run! => double(:output => ""))
        lv = described_class.create Pathname.new("/dev/#{@vg.name}/lv"), @vg, 256.gigabytes
        expect(lv.name).to eq("lv")
        expect(lv.path).to eq("/dev/vg/lv")
      end
    end

    it "adds logical volume to local registry" do
      allow(LinuxAdmin::VolumeGroup).to receive_messages(:run! => double(:output => ""))
      allow(described_class).to receive_messages(:run! => double(:output => ""))
      lv = described_class.create 'lv', @vg, 256.gigabytes
      expect(described_class.scan).to include(lv)
    end
  end

  describe "#scan" do
    it "uses lvdisplay" do
      expect(described_class).to receive(:run!).
                                with(LinuxAdmin.cmd(:lvdisplay),
                                     :params => { '-c' => nil}).
                                and_return(double(:output => @logical_volumes))
      expect(LinuxAdmin::VolumeGroup).to receive(:run!).and_return(double(:output => @groups)) # stub out call to vgdisplay
      described_class.scan
    end

    it "returns local logical volumes" do
      expect(described_class).to receive(:run!).and_return(double(:output => @logical_volumes))
      expect(LinuxAdmin::VolumeGroup).to receive(:run!).and_return(double(:output => @groups))
      lvs = described_class.scan

      expect(lvs[0]).to be_an_instance_of(described_class)
      expect(lvs[0].path).to eq('/dev/vg_foobar/lv_swap')
      expect(lvs[0].name).to eq('lv_swap')
      expect(lvs[0].sectors).to eq(4128768)

      expect(lvs[1]).to be_an_instance_of(described_class)
      expect(lvs[1].path).to eq('/dev/vg_foobar/lv_root')
      expect(lvs[1].name).to eq('lv_root')
      expect(lvs[1].sectors).to eq(19988480)
    end

    it "resolves volume group references" do
      expect(described_class).to receive(:run!).and_return(double(:output => @logical_volumes))
      expect(LinuxAdmin::VolumeGroup).to receive(:run!).and_return(double(:output => @groups))
      lvs = described_class.scan
      expect(lvs[0].volume_group).to be_an_instance_of(LinuxAdmin::VolumeGroup)
      expect(lvs[0].volume_group.name).to eq('vg_foobar')
      expect(lvs[1].volume_group).to be_an_instance_of(LinuxAdmin::VolumeGroup)
      expect(lvs[1].volume_group.name).to eq('vg_foobar')
    end
  end
end
