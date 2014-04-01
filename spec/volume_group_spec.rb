require 'spec_helper'

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
      vg.should_receive(:run!).
         with(vg.cmd(:lvextend),
              :params => ['lv', 'vg'])
      vg.attach_to(lv)
    end

    it "returns self" do
      vg = described_class.new :name => 'vg'
      lv = LinuxAdmin::LogicalVolume.new :name => 'lv', :volume_group => vg
      vg.stub(:run!)
      vg.attach_to(lv).should == vg
    end
  end

  describe "#extend_with" do
    it "uses vgextend" do
      vg = described_class.new :name => 'vg'
      pv = LinuxAdmin::PhysicalVolume.new :device_name => '/dev/hda'
      vg.should_receive(:run!).
         with(vg.cmd(:vgextend),
              :params => ['vg', '/dev/hda'])
      vg.extend_with(pv)
    end

    it "assigns volume group to physical volume" do
      vg = described_class.new :name => 'vg'
      pv = LinuxAdmin::PhysicalVolume.new :device_name => '/dev/hda'
      vg.stub(:run!)
      vg.extend_with(pv)
      pv.volume_group.should == vg
    end

    it "returns self" do
      vg = described_class.new :name => 'vg'
      pv = LinuxAdmin::PhysicalVolume.new :device_name => '/dev/hda'
      vg.stub(:run!)
      vg.extend_with(pv).should == vg
    end
  end

  describe "#create" do
    before(:each) do
      @pv = LinuxAdmin::PhysicalVolume.new :device_name => '/dev/hda'
    end

    it "uses vgcreate" do
      described_class.instance_variable_set(:@vgs, [])
      described_class.should_receive(:run!).
                              with(LinuxAdmin.cmd(:vgcreate),
                                   :params => ['vg', '/dev/hda'])
      described_class.create 'vg', @pv
    end

    it "returns new volume group" do
      described_class.stub(:run! => double(:output => ""))
      vg = described_class.create 'vg', @pv
      vg.should be_an_instance_of(described_class)
      vg.name.should == 'vg'
    end

    it "adds volume group to local registry" do
      described_class.stub(:run! => double(:output => ""))
      vg = described_class.create 'vg', @pv
      described_class.scan.should include(vg)
    end
  end

  describe "#scan" do
    it "uses vgdisplay" do
      described_class.should_receive(:run!).
                              with(LinuxAdmin.cmd(:vgdisplay),
                                   :params => { '-c' => nil}).
                                 and_return(double(:output => @groups))
      described_class.scan
    end

    it "returns local volume groups" do
      described_class.should_receive(:run!).and_return(double(:output => @groups))
      vgs = described_class.scan

      vgs[0].should be_an_instance_of(described_class)
      vgs[0].name.should == 'vg_foobar'
    end
  end
end
