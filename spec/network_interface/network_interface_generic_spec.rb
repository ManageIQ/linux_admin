describe LinuxAdmin::NetworkInterfaceGeneric do
  common_inst = Class.new { include LinuxAdmin::Common }.new

  IP_SHOW_ARGS = [
    common_inst.cmd("ip"),
    :params => %w(addr show eth0)
  ]

  IP_ROUTE_ARGS = [
    common_inst.cmd("ip"),
    :params => %w(route)
  ]

  IP_ADDR_SHOW_ETH0 = <<-IP_OUT
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:ed:0e:8b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.9/24 brd 192.168.1.255 scope global dynamic eth0
       valid_lft 1297sec preferred_lft 1297sec
    inet6 fe80::20c:29ff:feed:e8b/64 scope link
       valid_lft forever preferred_lft forever
    inet6 fd12:3456:789a:1::1/64 scope global
       valid_lft forever preferred_lft forever
IP_OUT

  IP_ROUTE = <<-IP_OUT
default via 192.168.1.1 dev eth0  proto static  metric 100
192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.9  metric 100
IP_OUT

  def result(output, exit_status)
    AwesomeSpawn::CommandResult.new("", output, "", exit_status)
  end

  subject do
    described_class.new("eth0")
  end

  describe "#address" do
    it "returns an address" do
      expect(AwesomeSpawn).to receive(:run).with(*IP_SHOW_ARGS).and_return(result(IP_ADDR_SHOW_ETH0, 0))
      expect(subject.address).to eq("192.168.1.9")
    end

    it "returns nil when no address is found" do
      expect(AwesomeSpawn).to receive(:run).with(*IP_SHOW_ARGS).and_return(result("", 1))
      expect(subject.address).to be_nil
    end
  end

  describe "#address6" do
    it "returns the global address by default" do
      expect(AwesomeSpawn).to receive(:run).with(*IP_SHOW_ARGS).and_return(result(IP_ADDR_SHOW_ETH0, 0))
      expect(subject.address6).to eq("fd12:3456:789a:1::1")
    end

    it "returns the link local address" do
      expect(AwesomeSpawn).to receive(:run).with(*IP_SHOW_ARGS).and_return(result(IP_ADDR_SHOW_ETH0, 0))
      expect(subject.address6(:link)).to eq("fe80::20c:29ff:feed:e8b")
    end

    it "returns nil when no address is found" do
      expect(AwesomeSpawn).to receive(:run).with(*IP_SHOW_ARGS).and_return(result("", 1))
      expect(subject.address6).to be_nil
    end
  end

  describe "#mac_address" do
    it "returns the correct MAC address" do
      expect(AwesomeSpawn).to receive(:run).with(*IP_SHOW_ARGS).and_return(result(IP_ADDR_SHOW_ETH0, 0))
      expect(subject.mac_address).to eq("00:0c:29:ed:0e:8b")
    end

    it "returns nil when the command fails" do
      expect(AwesomeSpawn).to receive(:run).with(*IP_SHOW_ARGS).and_return(result("", 1))
      expect(subject.mac_address).to be_nil
    end

    it "returns nil if the link/ether line is not present" do
      bad_output = IP_ADDR_SHOW_ETH0.gsub(%r{link/ether}, "")
      expect(AwesomeSpawn).to receive(:run).with(*IP_SHOW_ARGS).and_return(result(bad_output, 0))
      expect(subject.mac_address).to be_nil
    end
  end

  describe "#netmask" do
    it "returns the correct netmask" do
      expect(AwesomeSpawn).to receive(:run).with(*IP_SHOW_ARGS).and_return(result(IP_ADDR_SHOW_ETH0, 0))
      expect(subject.netmask).to eq("255.255.255.0")
    end

    it "returns nil when the command fails" do
      expect(AwesomeSpawn).to receive(:run).with(*IP_SHOW_ARGS).and_return(result("", 1))
      expect(subject.netmask).to be_nil
    end
  end

  describe "#gateway" do
    it "returns the correct gateway address" do
      expect(AwesomeSpawn).to receive(:run).with(*IP_ROUTE_ARGS).and_return(result(IP_ROUTE, 0))
      expect(subject.gateway).to eq("192.168.1.1")
    end

    it "returns nil when the command fails" do
      expect(AwesomeSpawn).to receive(:run).with(*IP_ROUTE_ARGS).and_return(result("", 1))
      expect(subject.gateway).to be_nil
    end

    it "returns nil if the default line is not present" do
      bad_output = IP_ROUTE.gsub(/default/, "")
      expect(AwesomeSpawn).to receive(:run).with(*IP_ROUTE_ARGS).and_return(result(bad_output, 0))
      expect(subject.gateway).to be_nil
    end
  end
end
