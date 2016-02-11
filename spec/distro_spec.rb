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
        etc_issue_contains('')
      end

      context "/etc/redhat-release exists" do
        it "returns Distros.rhel" do
          exists("/etc/fedora-release" => false, "/etc/redhat-release" => true, "/etc/mach_init.d" => false)
          expect(subject).to eq(LinuxAdmin::Distros.rhel)
        end
      end

      context "/etc/fedora-release exists" do
        it "returns Distros.fedora" do
          exists("/etc/fedora-release" => true, "/etc/redhat-release" => false, "/etc/mach_init.d" => false)
          expect(subject).to eq(LinuxAdmin::Distros.fedora)
        end
      end

      context "/etc/mach_init.d exists" do
        it "returns Distros.mac" do
          exists("/etc/fedora-release" => false, "/etc/redhat-release" => false, "/etc/mach_init.d" => true)
          expect(subject).to eq(LinuxAdmin::Distros.mac)
        end
      end

      it "returns Distros.generic" do
        exists("/etc/fedora-release" => false, "/etc/redhat-release" => false, "/etc/mach_init.d" => false)
        expect(subject).to eq(LinuxAdmin::Distros.generic)
      end
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

    it "dispatches to generic lookup mechanism" do
      stub_distro(LinuxAdmin::Distros.generic)
      expect { LinuxAdmin::Distros.local.info 'ruby' }.not_to raise_error
    end
  end

  private

  def exists(files)
    files.each_pair { |file, value| allow(File).to receive(:exist?).with(file).and_return(value) }
  end
end
