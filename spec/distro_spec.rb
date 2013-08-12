require 'spec_helper'

describe LinuxAdmin::Distro do
  describe "#local" do
    after(:each) do
      # distro generates a local copy, reset after each run
      LinuxAdmin::Distro.instance_variable_set(:@local, nil)
    end

    [['ubuntu',  :ubuntu],
     ['Fedora',  :redhat],
     ['red hat', :redhat],
     ['centos',  :redhat]].each do |i,d|
      context "/etc/issue contains '#{i}'" do
        before(:each) do
          File.should_receive(:exists?).with('/etc/issue').and_return(true)
          File.should_receive(:read).with('/etc/issue').and_return(i)
        end

        it "returns Distros.#{d}" do
          LinuxAdmin::Distro.local.should == LinuxAdmin::Distros.send(d)
        end
      end
    end

    context "/etc/issue did not match" do
      before(:each) do
        File.should_receive(:exists?).with('/etc/issue').and_return(false)
      end

      context "/etc/redhat-release exists" do
        it "returns Distros.redhat" do
          File.should_receive(:exists?).with('/etc/redhat-release').and_return(true)
          LinuxAdmin::Distro.local.should == LinuxAdmin::Distros.redhat
        end
      end

      context "/etc/fedora-release exists" do
        it "returns Distros.redhat" do
          File.should_receive(:exists?).with('/etc/redhat-release').and_return(false)
          File.should_receive(:exists?).with('/etc/fedora-release').and_return(true)
          LinuxAdmin::Distro.local.should == LinuxAdmin::Distros.redhat
        end
      end
    end

    it "returns Distros.generic" do
      File.stub(:exists?).and_return(false)
      LinuxAdmin::Distro.local.should == LinuxAdmin::Distros.generic
    end
  end
end
