require 'spec_helper'

describe LinuxAdmin::VolumeGroup do
  before(:each) do
    LinuxAdmin::Distro.stub(:local).
                       and_return(LinuxAdmin::Distros::Test.new)

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
    it "uses vgdisplay" do
      LinuxAdmin::VolumeGroup.should_receive(:run).
                              with(LinuxAdmin.cmd(:vgdisplay),
                                   :return_output => true,
                                   :params => { '-c' => nil}).
                                 and_return(@groups)
      LinuxAdmin::VolumeGroup.scan
    end

    it "returns local volume groups" do
      LinuxAdmin::VolumeGroup.should_receive(:run).and_return(@groups)
      vgs = LinuxAdmin::VolumeGroup.scan

      vgs[0].should be_an_instance_of(LinuxAdmin::VolumeGroup)
      vgs[0].name.should == 'vg_foobar'
    end
  end
end
