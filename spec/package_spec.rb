require 'spec_helper'

describe LinuxAdmin::Package do
  describe "#info" do
    it "dispatches to redhat lookup mechanism" do
      LinuxAdmin::Distro.should_receive(:local).and_return(LinuxAdmin::Distros.redhat)
      LinuxAdmin::Rpm.should_receive(:info).with('ruby')
      described_class.info 'ruby'
    end

    it "dispatches to ubuntu lookup mechanism" do
      LinuxAdmin::Distro.should_receive(:local).twice.and_return(LinuxAdmin::Distros.ubuntu)
      LinuxAdmin::Deb.should_receive(:info).with('ruby')
      described_class.info 'ruby'
    end
  end
end
