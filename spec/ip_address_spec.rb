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

  MASK_SPAWN_ARGS = [
    described_class.new.cmd("ifconfig"),
    :params => %w(eth0)
  ]

  GW_SPAWN_ARGS = [
    described_class.new.cmd("ip"),
    :params => %w(route)
  ]

  IP_ADDR_SHOW_ETH0 = <<-IP_OUT
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:ed:0e:8b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.9/24 brd 192.168.1.255 scope global dynamic eth0
       valid_lft 1297sec preferred_lft 1297sec
    inet6 fe80::20c:29ff:feed:e8b/64 scope link
       valid_lft forever preferred_lft forever

IP_OUT

  IFCFG = <<-IP_OUT
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.9  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::20c:29ff:feed:e8b  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:ed:0e:8b  txqueuelen 1000  (Ethernet)
        RX packets 10171  bytes 8163955 (7.7 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 2871  bytes 321915 (314.3 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

IP_OUT

  IP_ROUTE = <<-IP_OUT
default via 192.168.1.1 dev eth0  proto static  metric 100
192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.9  metric 100
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
      bad_output = IP_ADDR_SHOW_ETH0.gsub(%r{link/ether}, "")
      expect(AwesomeSpawn).to receive(:run).with(*MAC_SPAWN_ARGS).and_return(result(bad_output, 0))
      expect(ip.mac_address("eth0")).to be_nil
    end
  end

  describe "#netmask" do
    it "returns the correct netmask" do
      expect(AwesomeSpawn).to receive(:run).with(*MASK_SPAWN_ARGS).and_return(result(IFCFG, 0))
      expect(ip.netmask("eth0")).to eq("255.255.255.0")
    end

    it "returns nil when the command fails" do
      expect(AwesomeSpawn).to receive(:run).with(*MASK_SPAWN_ARGS).and_return(result("", 1))
      expect(ip.netmask("eth0")).to be_nil
    end

    it "returns nil if the netmask line is not present" do
      bad_output = IFCFG.gsub(/netmask/, "")
      expect(AwesomeSpawn).to receive(:run).with(*MASK_SPAWN_ARGS).and_return(result(bad_output, 0))
      expect(ip.netmask("eth0")).to be_nil
    end
  end

  describe "#gateway" do
    it "returns the correct gateway address" do
      expect(AwesomeSpawn).to receive(:run).with(*GW_SPAWN_ARGS).and_return(result(IP_ROUTE, 0))
      expect(ip.gateway).to eq("192.168.1.1")
    end

    it "returns nil when the command fails" do
      expect(AwesomeSpawn).to receive(:run).with(*GW_SPAWN_ARGS).and_return(result("", 1))
      expect(ip.gateway).to be_nil
    end

    it "returns nil if the default line is not present" do
      bad_output = IP_ROUTE.gsub(/default/, "")
      expect(AwesomeSpawn).to receive(:run).with(*GW_SPAWN_ARGS).and_return(result(bad_output, 0))
      expect(ip.gateway).to be_nil
    end
  end
end
