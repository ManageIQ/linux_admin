describe LinuxAdmin::IpAddress do
  let(:ip) { described_class.new }

  SPAWN_ARGS = [
    described_class.new.cmd("hostname"),
    :params => ["-I"]
  ]

  def result(output, exit_status)
    AwesomeSpawn::CommandResult.new("", output, "", exit_status)
  end

  describe "#address" do
    it "returns an address" do
      ip_addr = "192.168.1.2"
      expect(AwesomeSpawn).to receive(:run).with(*SPAWN_ARGS).and_return(result(ip_addr, 0))
      expect(ip.address).to eq(ip_addr)
    end

    it "returns nil when no address is found" do
      ip_addr = ""
      expect(AwesomeSpawn).to receive(:run).at_least(5).times.with(*SPAWN_ARGS).and_return(result(ip_addr, 1))
      expect(ip.address).to be_nil
    end

    it "returns only IPv4 addresses" do
      ip_addr = "fd12:3456:789a:1::1 192.168.1.2"
      expect(AwesomeSpawn).to receive(:run).with(*SPAWN_ARGS).and_return(result(ip_addr, 0))
      expect(ip.address).to eq("192.168.1.2")
    end
  end

  describe "#address6" do
    it "returns an address" do
      ip_addr = "fd12:3456:789a:1::1"
      expect(AwesomeSpawn).to receive(:run).with(*SPAWN_ARGS).and_return(result(ip_addr, 0))
      expect(ip.address6).to eq(ip_addr)
    end

    it "returns nil when no address is found" do
      ip_addr = ""
      expect(AwesomeSpawn).to receive(:run).at_least(5).times.with(*SPAWN_ARGS).and_return(result(ip_addr, 1))
      expect(ip.address6).to be_nil
    end

    it "returns only IPv6 addresses" do
      ip_addr = "192.168.1.2 fd12:3456:789a:1::1"
      expect(AwesomeSpawn).to receive(:run).with(*SPAWN_ARGS).and_return(result(ip_addr, 0))
      expect(ip.address6).to eq("fd12:3456:789a:1::1")
    end
  end
end
