require 'spec_helper'

describe LinuxAdmin::Distros::Distro do
  let(:subject) { LinuxAdmin::Distros.local }
  describe "#local" do
    before do
      LinuxAdmin::Distros.unstub(:local)
    end

    [['ubuntu',  :ubuntu],
     ['Fedora',  :fedora],
     ['red hat', :rhel],
     ['CentOS',  :rhel],
     ['centos',  :rhel]].each do |i, d|
      context "/etc/issue contains '#{i}'" do
        before(:each) do
          expect(LinuxAdmin::EtcIssue.instance).to receive(:to_s).at_least(:once).and_return(i)
          exists("/etc/fedora-release" => false, "/etc/redhat-release" => false)
        end

        it "returns Distros.#{d}" do
          distro = LinuxAdmin::Distros.send(d)
          expect(subject).to eq(distro)
        end
      end
    end

    context "/etc/issue did not match" do
      before(:each) do
        LinuxAdmin::EtcIssue.instance.should_receive(:to_s).at_least(:once).and_return('')
      end

      context "/etc/redhat-release exists" do
        it "returns Distros.rhel" do
          exists("/etc/fedora-release" => false, "/etc/redhat-release" => true)
          expect(subject).to eq(LinuxAdmin::Distros.rhel)
        end
      end

      context "/etc/fedora-release exists" do
        it "returns Distros.fedora" do
          exists("/etc/fedora-release" => true, "/etc/redhat-release" => false)
          expect(subject).to eq(LinuxAdmin::Distros.fedora)
        end
      end
    end

    it "returns Distros.generic" do
      LinuxAdmin::EtcIssue.instance.should_receive(:to_s).at_least(:once).and_return('')
      exists("/etc/fedora-release" => false, "/etc/redhat-release" => false)
      expect(subject).to eq(LinuxAdmin::Distros.generic)
    end
  end

  private

  def exists(files)
    files.each_pair { |file, value| allow(File).to receive(:exists?).with(file).and_return(value) }
  end
end
