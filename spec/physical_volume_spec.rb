require 'spec_helper'

describe LinuxAdmin::PhysicalVolume do
  before(:each) do
    LinuxAdmin::Distro.stub(:local).
                       and_return(LinuxAdmin::Distros::Test.new)

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
    LinuxAdmin::PhysicalVolume.instance_variable_set(:@pvs, nil)
    LinuxAdmin::VolumeGroup.instance_variable_set(:@vgs, nil)
  end

  describe "#scan" do
    it "uses pvdisplay" do
      LinuxAdmin::PhysicalVolume.should_receive(:run).
                                 with(LinuxAdmin.cmd(:pvdisplay),
                                     :return_output => true,
                                     :params => { '-c' => nil}).
                                 and_return(@physical_volumes)
      LinuxAdmin::VolumeGroup.should_receive(:run).and_return(@groups) # stub out call to vgdisplay
      LinuxAdmin::PhysicalVolume.scan
    end

    it "returns local physical volumes" do
      LinuxAdmin::PhysicalVolume.should_receive(:run).and_return(@physical_volumes)
      LinuxAdmin::VolumeGroup.should_receive(:run).and_return(@groups)
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
      pvs[0].volume_group.name.should == 'vg_foobar'
    end
  end
end
