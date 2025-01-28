describe LinuxAdmin::Distros::Distro do
  let(:subject) { LinuxAdmin::Distros.local }
  describe "#local" do
    before do
      allow(LinuxAdmin::Distros).to receive(:local).and_call_original
    end

    [['ubuntu',  :ubuntu],
     ['Fedora',  :fedora],
     ['red hat', :rhel],
     ['CentOS',  :rhel],
     ['centos',  :rhel]].each do |i, d|
      context "/etc/issue contains '#{i}'" do
        before(:each) do
          etc_issue_contains(i)
          exists("/etc/fedora-release" => false, "/etc/redhat-release" => false, "/System/Library/CoreServices/SystemVersion.plist" => false)
        end

        it "returns Distros.#{d}" do
          distro = LinuxAdmin::Distros.send(d)
          expect(subject).to eq(distro)
        end
      end
    end

    context "/etc/issue did not match" do
      before(:each) do
        etc_issue_contains('')
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

    it "returns Distro.darwin" do
      etc_issue_contains('')
      exists("/etc/fedora-release" => false, "/etc/redhat-release" => false, "/System/Library/CoreServices/SystemVersion.plist" => true)
      expect(subject).to eq(LinuxAdmin::Distros.darwin)
    end

    it "returns Distros.generic" do
      etc_issue_contains('')
      exists("/etc/fedora-release" => false, "/etc/redhat-release" => false, "/System/Library/CoreServices/SystemVersion.plist" => false)
      expect(subject).to eq(LinuxAdmin::Distros.generic)
    end
  end

  describe "#info" do
    it "dispatches to redhat lookup mechanism" do
      stub_distro(LinuxAdmin::Distros.rhel)
      expect(LinuxAdmin::Rpm).to receive(:info).with('ruby')
      LinuxAdmin::Distros.local.info 'ruby'
    end

    it "dispatches to ubuntu lookup mechanism" do
      stub_distro(LinuxAdmin::Distros.ubuntu)
      expect(LinuxAdmin::Deb).to receive(:info).with('ruby')
      LinuxAdmin::Distros.local.info 'ruby'
    end

    it "dispatches to ubuntu lookup mechanism" do
      stub_distro(LinuxAdmin::Distros.generic)
      expect { LinuxAdmin::Distros.local.info 'ruby' }.not_to raise_error
    end
  end

  private

  def exists(files)
    files.each_pair { |file, value| allow(File).to receive(:exist?).with(file).and_return(value) }
  end
end
