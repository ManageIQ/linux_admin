require 'spec_helper'

describe LinuxAdmin::LogicalVolume do
  before(:each) do
    LinuxAdmin::Distro.stub(:local).
                       and_return(LinuxAdmin::Distros::Test.new)

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
    LinuxAdmin::LogicalVolume.instance_variable_set(:@lvs, nil)
    LinuxAdmin::PhysicalVolume.instance_variable_set(:@pvs, nil)
    LinuxAdmin::VolumeGroup.instance_variable_set(:@vgs, nil)
  end

  describe "#scan" do
    it "uses lvdisplay" do
      LinuxAdmin::LogicalVolume.should_receive(:run).
                                with(LinuxAdmin.cmd(:lvdisplay),
                                     :return_output => true,
                                     :params => { '-c' => nil}).
                                and_return(@logical_volumes)
      LinuxAdmin::VolumeGroup.should_receive(:run).and_return(@groups) # stub out call to vgdisplay
      LinuxAdmin::LogicalVolume.scan
    end

    it "returns local logical volumes" do
      LinuxAdmin::LogicalVolume.should_receive(:run).and_return(@logical_volumes)
      LinuxAdmin::VolumeGroup.should_receive(:run).and_return(@groups)
      lvs = LinuxAdmin::LogicalVolume.scan

      lvs[0].should be_an_instance_of(LinuxAdmin::LogicalVolume)
      lvs[0].name.should == '/dev/vg_foobar/lv_swap'
      lvs[0].sectors.should == 4128768

      lvs[1].should be_an_instance_of(LinuxAdmin::LogicalVolume)
      lvs[1].name.should == '/dev/vg_foobar/lv_root'
      lvs[1].sectors.should == 19988480
    end

    it "resolves volume group references" do
      LinuxAdmin::LogicalVolume.should_receive(:run).and_return(@logical_volumes)
      LinuxAdmin::VolumeGroup.should_receive(:run).and_return(@groups)
      lvs = LinuxAdmin::LogicalVolume.scan
      lvs[0].volume_group.should be_an_instance_of(LinuxAdmin::VolumeGroup)
      lvs[0].volume_group.name.should == 'vg_foobar'
      lvs[1].volume_group.should be_an_instance_of(LinuxAdmin::VolumeGroup)
      lvs[1].volume_group.name.should == 'vg_foobar'
    end
  end
end
