require 'spec_helper'

describe LinuxAdmin::Distros::Distro do
  describe "#local" do
    [['ubuntu',  :ubuntu],
     ['Fedora',  :fedora],
     ['red hat', :rhel],
     ['CentOS',  :rhel],
     ['centos',  :rhel]].each do |i, d|
      context "/etc/issue contains '#{i}'" do
        before(:each) do
          LinuxAdmin::EtcIssue.instance.should_receive(:to_s).at_least(:once).and_return(i)
          File.should_receive(:exists?).at_least(:once).and_return(false)
        end

        it "returns Distros.#{d}" do
          distro = LinuxAdmin::Distros.send(d)
          described_class.local.should == distro
        end
      end
    end

    context "/etc/issue did not match" do
      before(:each) do
        LinuxAdmin::EtcIssue.instance.should_receive(:to_s).at_least(:once).and_return('')
      end

      context "/etc/redhat-release exists" do
        it "returns Distros.rhel" do
          File.should_receive(:exists?).with('/etc/redhat-release').and_return(true)
          LinuxAdmin::Distros::Fedora.should_receive(:detected?).and_return(false)
          File.should_receive(:exists?).at_least(:once).and_call_original
          described_class.local.should == LinuxAdmin::Distros.rhel
        end
      end

      context "/etc/fedora-release exists" do
        it "returns Distros.fedora" do
          File.should_receive(:exists?).with('/etc/redhat-release').and_return(false)
          File.should_receive(:exists?).with('/etc/fedora-release').and_return(true)
          File.should_receive(:exists?).at_least(:once).and_call_original
          described_class.local.should == LinuxAdmin::Distros.fedora
        end
      end
    end

    it "returns Distros.generic" do
      LinuxAdmin::EtcIssue.instance.should_receive(:to_s).at_least(:once).and_return('')
      File.should_receive(:exists?).at_least(:once).and_return(false)
      described_class.local.should == LinuxAdmin::Distros.generic
    end
  end
end
