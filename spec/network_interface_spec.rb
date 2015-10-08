describe LinuxAdmin::NetworkInterface do
  context "on redhat systems" do
    subject do
      allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.rhel)
      described_class.dist_class(true)
      allow(File).to receive(:read).and_return("")
      described_class.new("eth0")
    end

    describe ".dist_class" do
      it "returns NetworkInterfaceRH" do
        allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.rhel)
        expect(described_class.dist_class(true)).to eq(LinuxAdmin::NetworkInterfaceRH)
      end
    end

    describe ".new" do
      it "creates a NetworkInterfaceRH instance" do
        expect(subject).to be_an_instance_of(LinuxAdmin::NetworkInterfaceRH)
      end
    end
  end

  context "on other linux systems" do
    subject do
      allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.generic)
      described_class.dist_class(true)
      described_class.new("eth0")
    end

    describe ".dist_class" do
      it "returns NetworkInterfaceGeneric" do
        allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.generic)
        expect(described_class.dist_class(true)).to eq(LinuxAdmin::NetworkInterfaceGeneric)
      end
    end

    describe ".new" do
      it "creates a NetworkInterfaceGeneric instance" do
        expect(subject).to be_an_instance_of(LinuxAdmin::NetworkInterfaceGeneric)
      end
    end
  end
end
