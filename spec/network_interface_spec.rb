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

    IFUP_ARGS = [
      common_inst.cmd("ifup"),
      :params => ["eth0"]
    ]

    IFDOWN_ARGS = [
      common_inst.cmd("ifdown"),
      :params => ["eth0"]
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

      allow(AwesomeSpawn).to receive(:run!).with(*IP_SHOW_ARGS).and_return(result(IP_ADDR_OUT, 0))
      allow(AwesomeSpawn).to receive(:run!).with(*IP_ROUTE_ARGS).and_return(result(IP_ROUTE_OUT, 0))
      described_class.new("eth0")
    end

    def result(output, exit_status)
      AwesomeSpawn::CommandResult.new("", output, "", exit_status)
    end

    describe "#reload" do
      it "raises when ip addr show fails" do
        subj
        awesome_error = AwesomeSpawn::CommandResultError.new("", nil)
        allow(AwesomeSpawn).to receive(:run!).with(*IP_SHOW_ARGS).and_raise(awesome_error)
        expect { subj.reload }.to raise_error(described_class::NetworkInterfaceError)
      end

      it "raises when ip route fails" do
        subj
        awesome_error = AwesomeSpawn::CommandResultError.new("", nil)
        allow(AwesomeSpawn).to receive(:run!).with(*IP_SHOW_ARGS).and_return(result(IP_ADDR_OUT, 0))
        allow(AwesomeSpawn).to receive(:run!).with(*IP_ROUTE_ARGS).and_raise(awesome_error)
        expect { subj.reload }.to raise_error(described_class::NetworkInterfaceError)
      end
    end

    describe "#address" do
      it "returns an address" do
        expect(subj.address).to eq("192.168.1.9")
      end
    end

    describe "#address6" do
      it "returns the global address by default" do
        expect(subj.address6).to eq("fd12:3456:789a:1::1")
      end

      it "returns the link local address" do
        expect(subj.address6(:link)).to eq("fe80::20c:29ff:feed:e8b")
      end

      it "raises ArgumentError when given a bad scope" do
        expect { subj.address6(:garbage) }.to raise_error(ArgumentError)
      end
    end

    describe "#mac_address" do
      it "returns the correct MAC address" do
        expect(subj.mac_address).to eq("00:0c:29:ed:0e:8b")
      end
    end

    describe "#netmask" do
      it "returns the correct netmask" do
        expect(subj.netmask).to eq("255.255.255.0")
      end
    end

    describe "#netmask6" do
      it "returns the correct global netmask" do
        expect(subj.netmask6).to eq("ffff:ffff:ffff:ffff:ffff:ffff::")
      end

      it "returns the correct link local netmask" do
        expect(subj.netmask6(:link)).to eq("ffff:ffff:ffff:ffff::")
      end

      it "raises ArgumentError when given a bad scope" do
        expect { subj.netmask6(:garbage) }.to raise_error(ArgumentError)
      end
    end

    describe "#gateway" do
      it "returns the correct gateway address" do
        expect(subj.gateway).to eq("192.168.1.1")
      end
    end

    describe "#start" do
      it "returns true on success" do
        expect(AwesomeSpawn).to receive(:run).with(*IFUP_ARGS).and_return(result("", 0))
        expect(subj.start).to be true
      end

      it "returns false on failure" do
        expect(AwesomeSpawn).to receive(:run).with(*IFUP_ARGS).and_return(result("", 1))
        expect(subj.start).to be false
      end
    end

    describe "#stop" do
      it "returns true on success" do
        expect(AwesomeSpawn).to receive(:run).with(*IFDOWN_ARGS).and_return(result("", 0))
        expect(subj.stop).to be true
      end

      it "returns false on failure" do
        expect(AwesomeSpawn).to receive(:run).with(*IFDOWN_ARGS).and_return(result("", 1))
        expect(subj.stop).to be false
      end
    end
  end
end
