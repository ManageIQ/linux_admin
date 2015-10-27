describe LinuxAdmin::NetworkInterfaceRH do
  DEVICE_NAME = "eth0"
  IFCFG_FILE_DHCP = <<-EOF
#A comment is here
DEVICE=eth0
BOOTPROTO=dhcp
UUID=3a48a5b5-b80b-4712-82f7-e517e4088999
ONBOOT=yes
TYPE=Ethernet
NAME="System eth0"
EOF

  IFCFG_FILE_STATIC = <<-EOF
#A comment is here
DEVICE=eth0
BOOTPROTO=static
UUID=3a48a5b5-b80b-4712-82f7-e517e4088999
ONBOOT=yes
TYPE=Ethernet
NAME="System eth0"
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
EOF

  def stub_foreach_to_string(string)
    allow(File).to receive(:foreach) do |&block|
      string.each_line { |l| block.call(l) }
    end
  end

  def result(output, exit_status)
    AwesomeSpawn::CommandResult.new("", output, "", exit_status)
  end

  subject(:dhcp_interface) do
    allow(File).to receive(:exist?).and_return(true)
    stub_foreach_to_string(IFCFG_FILE_DHCP)
    allow(AwesomeSpawn).to receive(:run!).twice.and_return(result("", 0))
    described_class.new(DEVICE_NAME)
  end

  subject(:static_interface) do
    allow(File).to receive(:exist?).and_return(true)
    stub_foreach_to_string(IFCFG_FILE_STATIC)
    allow(AwesomeSpawn).to receive(:run!).twice.and_return(result("", 0))
    described_class.new(DEVICE_NAME)
  end

  describe ".new" do
    it "loads the configuration" do
      conf = dhcp_interface.interface_config
      expect(conf["NM_CONTROLLED"]).to eq("no")
      expect(conf["DEVICE"]).to        eq("eth0")
      expect(conf["BOOTPROTO"]).to     eq("dhcp")
      expect(conf["UUID"]).to          eq("3a48a5b5-b80b-4712-82f7-e517e4088999")
      expect(conf["ONBOOT"]).to        eq("yes")
      expect(conf["TYPE"]).to          eq("Ethernet")
      expect(conf["NAME"]).to          eq('"System eth0"')
    end
  end

  describe "#parse_conf" do
    it "reloads the interface configuration" do
      interface = dhcp_interface
      stub_foreach_to_string(IFCFG_FILE_STATIC)
      interface.parse_conf

      conf = interface.interface_config
      expect(conf["NM_CONTROLLED"]).to eq("no")
      expect(conf["DEVICE"]).to        eq("eth0")
      expect(conf["BOOTPROTO"]).to     eq("static")
      expect(conf["UUID"]).to          eq("3a48a5b5-b80b-4712-82f7-e517e4088999")
      expect(conf["ONBOOT"]).to        eq("yes")
      expect(conf["TYPE"]).to          eq("Ethernet")
      expect(conf["NAME"]).to          eq('"System eth0"')
      expect(conf["IPADDR"]).to        eq("192.168.1.100")
      expect(conf["NETMASK"]).to       eq("255.255.255.0")
      expect(conf["GATEWAY"]).to       eq("192.168.1.1")
    end
  end

  describe "#address=" do
    it "sets the address" do
      address = "192.168.1.100"

      dhcp_interface.address = address

      conf = dhcp_interface.interface_config
      expect(conf["IPADDR"]).to    eq(address)
      expect(conf["BOOTPROTO"]).to eq("static")
    end

    it "raises argument error when given a bad address" do
      expect { dhcp_interface.address = "garbage" }.to raise_error(ArgumentError)
    end
  end

  describe "#gateway=" do
    it "sets the gateway address" do
      address = "192.168.1.1"
      dhcp_interface.gateway = address
      expect(dhcp_interface.interface_config["GATEWAY"]).to eq(address)
    end

    it "raises argument error when given a bad address" do
      expect { dhcp_interface.gateway = "garbage" }.to raise_error(ArgumentError)
    end
  end

  describe "#netmask=" do
    it "sets the sub-net mask" do
      mask = "255.255.255.0"
      dhcp_interface.netmask = mask
      expect(dhcp_interface.interface_config["NETMASK"]).to eq(mask)
    end

    it "raises argument error when given a bad address" do
      expect { dhcp_interface.netmask = "garbage" }.to raise_error(ArgumentError)
    end
  end

  describe "#dns=" do
    it "sets the correct configuration" do
      dns1 = "192.168.1.1"
      dns2 = "192.168.1.10"

      static_interface.dns = dns1, dns2

      conf = static_interface.interface_config
      expect(conf["DNS1"]).to eq(dns1)
      expect(conf["DNS2"]).to eq(dns2)
    end

    it "sets the correct configuration when given an array" do
      dns = %w(192.168.1.1 192.168.1.10)

      static_interface.dns = dns

      conf = static_interface.interface_config
      expect(conf["DNS1"]).to eq(dns[0])
      expect(conf["DNS2"]).to eq(dns[1])
    end

    it "sets only DNS1 if given one value" do
      dns = "192.168.1.1"

      static_interface.dns = dns

      conf = static_interface.interface_config
      expect(conf["DNS1"]).to eq(dns)
      expect(conf["DNS2"]).to be_nil
    end
  end

  describe "#search_order=" do
    it "sets the search domain list" do
      search1 = "localhost"
      search2 = "test.example.com"
      search3 = "example.com"
      static_interface.search_order = search1, search2, search3
      expect(static_interface.interface_config["DOMAIN"]).to eq("\"#{search1} #{search2} #{search3}\"")
    end

    it "sets the search domain list when given an array" do
      search_list = %w(localhost test.example.com example.com)
      static_interface.search_order = search_list
      expect(static_interface.interface_config["DOMAIN"]).to eq("\"#{search_list.join(' ')}\"")
    end
  end

  describe "#enable_dhcp" do
    it "sets the correct configuration" do
      static_interface.enable_dhcp
      conf = static_interface.interface_config
      expect(conf["BOOTPROTO"]).to eq("dhcp")
      expect(conf["IPADDR"]).to    be_nil
      expect(conf["NETMASK"]).to   be_nil
      expect(conf["GATEWAY"]).to   be_nil
      expect(conf["PREFIX"]).to    be_nil
    end
  end

  describe "#apply_static" do
    it "sets the correct configuration" do
      expect(dhcp_interface).to receive(:save)
      dhcp_interface.apply_static("192.168.1.12", "255.255.255.0", "192.168.1.1", ["192.168.1.1", nil], ["localhost"])

      conf = dhcp_interface.interface_config
      expect(conf["BOOTPROTO"]).to eq("static")
      expect(conf["IPADDR"]).to    eq("192.168.1.12")
      expect(conf["NETMASK"]).to   eq("255.255.255.0")
      expect(conf["GATEWAY"]).to   eq("192.168.1.1")
      expect(conf["DNS1"]).to      eq("192.168.1.1")
      expect(conf["DNS2"]).to      be_nil
      expect(conf["DOMAIN"]).to    eq("\"localhost\"")
    end
  end

  describe "#save" do
    let(:iface_file) { Pathname.new("/etc/sysconfig/network-scripts/ifcfg-#{DEVICE_NAME}") }

    def expect_old_contents
      expect(File).to receive(:write) do |file, contents|
        expect(file).to eq(iface_file)
        expect(contents).to include("DEVICE=eth0")
        expect(contents).to include("BOOTPROTO=dhcp")
        expect(contents).to include("UUID=3a48a5b5-b80b-4712-82f7-e517e4088999")
        expect(contents).to include("ONBOOT=yes")
        expect(contents).to include("TYPE=Ethernet")
        expect(contents).to include('NAME="System eth0"')
      end
    end

    it "writes the configuration" do
      expect(File).to receive(:read).with(iface_file)
      expect(dhcp_interface).to receive(:stop).and_return(true)
      expect(dhcp_interface).to receive(:start).and_return(true)
      expect_old_contents
      expect(dhcp_interface.save).to be true
    end

    it "returns false when the interface cannot be brought down" do
      expect(File).to receive(:read).with(iface_file)
      expect(dhcp_interface).to receive(:stop).and_return(false)
      expect(File).not_to receive(:write)
      expect(dhcp_interface.save).to be false
    end

    it "returns false and writes the old contents when the interface fails to come back up" do
      dhcp_interface # evaluate the subject first so the expectations stub the right calls
      expect(File).to receive(:read).with(iface_file).and_return("old stuff")
      expect(dhcp_interface).to receive(:stop).and_return(true)
      expect_old_contents
      expect(dhcp_interface).to receive(:start).and_return(false)
      expect(File).to receive(:write).with(iface_file, "old stuff")
      expect(dhcp_interface).to receive(:start)
      expect(dhcp_interface.save).to be false
    end
  end
end
