describe LinuxAdmin::NetworkInterface do
  context "on redhat systems" do
    subject do
      allow_any_instance_of(described_class).to receive(:ip_show).and_return(nil)
      allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.rhel)
      described_class.dist_class(true)
      allow(File).to receive(:foreach).and_return("")
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
      allow_any_instance_of(described_class).to receive(:ip_show).and_return(nil)
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

  context "on all systems" do
    common_inst = Class.new { include LinuxAdmin::Common }.new

    IP_SHOW_ARGS = [
      common_inst.cmd("ip"),
      :params => %w(addr show eth0)
    ]

    IP_ROUTE_ARGS = [
      common_inst.cmd("ip"),
      :params => %w(route)
    ]

    IP_ADDR_OUT = <<-IP_OUT
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:ed:0e:8b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.9/24 brd 192.168.1.255 scope global dynamic eth0
       valid_lft 1297sec preferred_lft 1297sec
    inet6 fe80::20c:29ff:feed:e8b/64 scope link
       valid_lft forever preferred_lft forever
    inet6 fd12:3456:789a:1::1/96 scope global
       valid_lft forever preferred_lft forever
IP_OUT

    IP_ROUTE_OUT = <<-IP_OUT
default via 192.168.1.1 dev eth0  proto static  metric 100
192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.9  metric 100
IP_OUT

    subject(:subj) do
      allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.generic)
      described_class.dist_class(true)

      allow(AwesomeSpawn).to receive(:run).with(*IP_SHOW_ARGS).and_return(result(IP_ADDR_OUT, 0))
      allow(AwesomeSpawn).to receive(:run).with(*IP_ROUTE_ARGS).and_return(result(IP_ROUTE_OUT, 0))
      described_class.new("eth0")
    end

    subject(:error_subj) do
      allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.generic)
      described_class.dist_class(true)

      allow(AwesomeSpawn).to receive(:run).with(*IP_SHOW_ARGS).and_return(result("", 1))
      allow(AwesomeSpawn).to receive(:run).with(*IP_ROUTE_ARGS).and_return(result("", 1))
      described_class.new("eth0")
    end

    def result(output, exit_status)
      AwesomeSpawn::CommandResult.new("", output, "", exit_status)
    end

    describe "#address" do
      it "returns an address" do
        expect(subj.address).to eq("192.168.1.9")
      end

      it "returns nil when no address is found" do
        expect(error_subj.address).to be_nil
      end
    end

    describe "#address6" do
      it "returns the global address by default" do
        expect(subj.address6).to eq("fd12:3456:789a:1::1")
      end

      it "returns the link local address" do
        expect(subj.address6(:link)).to eq("fe80::20c:29ff:feed:e8b")
      end

      it "returns nil when no address is found" do
        expect(error_subj.address6).to be_nil
      end

      it "raises ArgumentError when given a bad scope" do
        expect { subj.address6(:garbage) }.to raise_error(ArgumentError)
      end
    end

    describe "#mac_address" do
      it "returns the correct MAC address" do
        expect(subj.mac_address).to eq("00:0c:29:ed:0e:8b")
      end

      it "returns nil when the command fails" do
        expect(error_subj.mac_address).to be_nil
      end
    end

    describe "#netmask" do
      it "returns the correct netmask" do
        expect(subj.netmask).to eq("255.255.255.0")
      end

      it "returns nil when the command fails" do
        expect(error_subj.netmask).to be_nil
      end
    end

    describe "#netmask6" do
      it "returns the correct global netmask" do
        expect(subj.netmask6).to eq("ffff:ffff:ffff:ffff:ffff:ffff::")
      end

      it "returns the correct link local netmask" do
        expect(subj.netmask6(:link)).to eq("ffff:ffff:ffff:ffff::")
      end

      it "returns nil when the command fails" do
        expect(error_subj.netmask6).to be_nil
      end

      it "raises ArgumentError when given a bad scope" do
        expect { subj.netmask6(:garbage) }.to raise_error(ArgumentError)
      end
    end

    describe "#gateway" do
      it "returns the correct gateway address" do
        expect(subj.gateway).to eq("192.168.1.1")
      end

      it "returns nil when the command fails" do
        expect(error_subj.gateway).to be_nil
      end
    end
  end
end