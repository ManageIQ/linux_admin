require 'spec_helper'

def setup_volumes
  @logical_volumes = <<eos
/dev/vg_morsi/lv_swap:vg_morsi:3:1:-1:2:4128768:63:-1:0:-1:253:0
/dev/vg_morsi/lv_root:vg_morsi:3:1:-1:1:19988480:305:-1:0:-1:253:1
eos

  @physical_volumes = <<eos
/dev/vda2:vg_morsi:24139776:-1:8:8:-1:32768:368:0:368:pxR32D-YkC2-PfHe-zOwb-eaGD-9Ar0-mAOl9u
eos

  @groups = <<eos
vg_morsi:r/w:772:-1:0:2:2:-1:0:1:1:12058624:32768:368:368:0:tILZUF-IspH-H90I-pT5j-vVFl-b76L-zWx3CW
eos
end

def teardown_volumes
  # reset local copies of volumes / groups
  LinuxAdmin::LogicalVolume.instance_variable_set(:@lvs, nil)
  LinuxAdmin::PhysicalVolume.instance_variable_set(:@pvs, nil)
  LinuxAdmin::VolumeGroup.instance_variable_set(:@vgs, nil)
end

describe LinuxAdmin::LogicalVolume do
  before(:each) do
    setup_volumes
  end

  after(:each) do
    teardown_volumes
  end

  describe "#scan" do
    it "uses lvdisplay" do
      LinuxAdmin::LogicalVolume.should_receive(:run).
                                with(LinuxAdmin.cmd(:lvdisplay),
                                     :return_output => true,
                                     :params => { nil => ['-c']}).
                                and_return(@logical_volumes)
      LinuxAdmin::LogicalVolume.scan
    end

    it "returns local logical volumes" do
      LinuxAdmin::LogicalVolume.should_receive(:run).and_return(@logical_volumes)
      lvs = LinuxAdmin::LogicalVolume.scan

      lvs[0].should be_an_instance_of(LinuxAdmin::LogicalVolume)
      lvs[0].name.should == '/dev/vg_morsi/lv_swap'
      lvs[0].sectors.should == 4128768

      lvs[1].should be_an_instance_of(LinuxAdmin::LogicalVolume)
      lvs[1].name.should == '/dev/vg_morsi/lv_root'
      lvs[1].sectors.should == 19988480
    end

    it "resolves volume group references" do
      LinuxAdmin::LogicalVolume.should_receive(:run).and_return(@logical_volumes)
      LinuxAdmin::VolumeGroup.should_receive(:run).and_return(@groups)
      lvs = LinuxAdmin::LogicalVolume.scan
      lvs[0].volume_group.should be_an_instance_of(LinuxAdmin::VolumeGroup)
      lvs[0].volume_group.name.should == 'vg_morsi'
      lvs[1].volume_group.should be_an_instance_of(LinuxAdmin::VolumeGroup)
      lvs[1].volume_group.name.should == 'vg_morsi'
    end
  end
end

describe LinuxAdmin::PhysicalVolume do
  before(:each) do
    setup_volumes
  end

  after(:each) do
    teardown_volumes
  end

  describe "#scan" do
    it "uses pvdisplay" do
      LinuxAdmin::PhysicalVolume.should_receive(:run).
                                 with(LinuxAdmin.cmd(:pvdisplay),
                                     :return_output => true,
                                     :params => { nil => ['-c']}).
                                 and_return(@physical_volumes)
      LinuxAdmin::PhysicalVolume.scan
    end

    it "returns local physical volumes" do
      LinuxAdmin::PhysicalVolume.should_receive(:run).and_return(@physical_volumes)
      pvs = LinuxAdmin::PhysicalVolume.scan

      pvs[0].should be_an_instance_of(LinuxAdmin::PhysicalVolume)
      pvs[0].device_name.should == '/dev/vda2'
      pvs[0].size.should == 24139776
    end

    it "resolves volume group references" do
      LinuxAdmin::PhysicalVolume.should_receive(:run).and_return(@physical_volumes)
      LinuxAdmin::VolumeGroup.should_receive(:run).and_return(@groups)
      pvs = LinuxAdmin::PhysicalVolume.scan
      pvs[0].volume_group.should be_an_instance_of(LinuxAdmin::VolumeGroup)
      pvs[0].volume_group.name.should == 'vg_morsi'
    end
  end
end

describe LinuxAdmin::VolumeGroup do
  before(:each) do
    setup_volumes
  end

  after(:each) do
    teardown_volumes
  end

  describe "#scan" do
    it "uses vgdisplay" do
      LinuxAdmin::VolumeGroup.should_receive(:run).
                              with(LinuxAdmin.cmd(:vgdisplay),
                                   :return_output => true,
                                   :params => { nil => ['-c']}).
                                 and_return(@groups)
      LinuxAdmin::VolumeGroup.scan
    end

    it "returns local volume groups" do
      LinuxAdmin::VolumeGroup.should_receive(:run).and_return(@groups)
      vgs = LinuxAdmin::VolumeGroup.scan

      vgs[0].should be_an_instance_of(LinuxAdmin::VolumeGroup)
      vgs[0].name.should == 'vg_morsi'
    end
  end
end
