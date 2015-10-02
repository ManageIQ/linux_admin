describe LinuxAdmin::IpAddress do
  let(:ip) { described_class.new }

  ADDR_SPAWN_ARGS = [
    described_class.new.cmd("hostname"),
    :params => ["-I"]
  ]

  MAC_SPAWN_ARGS = [
    described_class.new.cmd("ip"),
    :params => %w(addr show eth0)
  ]

  IP_ADDR_SHOW_ETH0 = <<-IP_OUT
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:ed:0e:8b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.9/24 brd 192.168.1.255 scope global dynamic eth0
       valid_lft 1297sec preferred_lft 1297sec
    inet6 fe80::20c:29ff:feed:e8b/64 scope link
       valid_lft forever preferred_lft forever

IP_OUT

  IP_ADDR_ERR = <<-IP_OUT
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    inet 192.168.1.9/24 brd 192.168.1.255 scope global dynamic eth0
       valid_lft 1297sec preferred_lft 1297sec
    inet6 fe80::20c:29ff:feed:e8b/64 scope link
       valid_lft forever preferred_lft forever

IP_OUT

  def result(output, exit_status)
    AwesomeSpawn::CommandResult.new("", output, "", exit_status)
  end

  describe "#address" do
    it "returns an address" do
      ip_addr = "192.168.1.2"
      expect(AwesomeSpawn).to receive(:run).with(*ADDR_SPAWN_ARGS).and_return(result(ip_addr, 0))
      expect(ip.address).to eq(ip_addr)
    end

    it "returns nil when no address is found" do
      ip_addr = ""
      expect(AwesomeSpawn).to receive(:run).at_least(5).times.with(*ADDR_SPAWN_ARGS).and_return(result(ip_addr, 1))
      expect(ip.address).to be_nil
    end

    it "returns only IPv4 addresses" do
      ip_addr = "fd12:3456:789a:1::1 192.168.1.2"
      expect(AwesomeSpawn).to receive(:run).with(*ADDR_SPAWN_ARGS).and_return(result(ip_addr, 0))
      expect(ip.address).to eq("192.168.1.2")
    end
  end

  describe "#address6" do
    it "returns an address" do
      ip_addr = "fd12:3456:789a:1::1"
      expect(AwesomeSpawn).to receive(:run).with(*ADDR_SPAWN_ARGS).and_return(result(ip_addr, 0))
      expect(ip.address6).to eq(ip_addr)
    end

    it "returns nil when no address is found" do
      ip_addr = ""
      expect(AwesomeSpawn).to receive(:run).at_least(5).times.with(*ADDR_SPAWN_ARGS).and_return(result(ip_addr, 1))
      expect(ip.address6).to be_nil
    end

    it "returns only IPv6 addresses" do
      ip_addr = "192.168.1.2 fd12:3456:789a:1::1"
      expect(AwesomeSpawn).to receive(:run).with(*ADDR_SPAWN_ARGS).and_return(result(ip_addr, 0))
      expect(ip.address6).to eq("fd12:3456:789a:1::1")
    end
  end

  describe "#mac_address" do
    it "returns the correct MAC address" do
      expect(AwesomeSpawn).to receive(:run).with(*MAC_SPAWN_ARGS).and_return(result(IP_ADDR_SHOW_ETH0, 0))
      expect(ip.mac_address("eth0")).to eq("00:0c:29:ed:0e:8b")
    end

    it "returns nil when the command fails" do
      expect(AwesomeSpawn).to receive(:run).with(*MAC_SPAWN_ARGS).and_return(result("", 1))
      expect(ip.mac_address("eth0")).to be_nil
    end

    it "returns nil if the link/ether line is not present" do
      expect(AwesomeSpawn).to receive(:run).with(*MAC_SPAWN_ARGS).and_return(result(IP_ADDR_ERR, 0))
      expect(ip.mac_address("eth0")).to be_nil
    end
  end
end
