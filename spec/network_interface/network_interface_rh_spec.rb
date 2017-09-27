describe LinuxAdmin::NetworkInterfaceRH do
  let(:device_name) { "eth0" }
  let(:ifcfg_file_dhcp) do
    <<-EOF
#A comment is here
DEVICE=eth0
BOOTPROTO=dhcp
UUID=3a48a5b5-b80b-4712-82f7-e517e4088999
ONBOOT=yes
TYPE=Ethernet
NAME="System eth0"
EOF
  end

  let(:ifcfg_file_static) do
    <<-EOF
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
  end

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
    stub_path = described_class.path_to_interface_config_file(device_name)
    allow(Pathname).to receive(:new).and_return(stub_path)
    allow(stub_path).to receive(:file?).and_return(true)
    stub_foreach_to_string(ifcfg_file_dhcp)
    allow(AwesomeSpawn).to receive(:run!).exactly(4).times.and_return(result("", 0))
    described_class.new(device_name)
  end

  subject(:static_interface) do
    allow(File).to receive(:exist?).and_return(true)
    stub_foreach_to_string(ifcfg_file_static)
    allow(AwesomeSpawn).to receive(:run!).exactly(4).times.and_return(result("", 0))
    described_class.new(device_name)
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
      stub_foreach_to_string(ifcfg_file_static)
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

  describe '#address6=' do
    it 'sets the ipv6 address' do
      address = 'fe80::1/64'
      dhcp_interface.address6 = address
      conf = dhcp_interface.interface_config
      expect(conf['IPV6ADDR']).to eq(address)
      expect(conf['IPV6INIT']).to eq('yes')
      expect(conf['DHCPV6C']).to eq('no')
    end

    it 'raises error when given a bad address' do
      expect { dhcp_interface.address6 = '1::1::1' }.to raise_error(ArgumentError)
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

  describe '#gateway6=' do
    it 'sets the default gateway for IPv6' do
      address = 'fe80::1/64'
      dhcp_interface.gateway6 = address
      expect(dhcp_interface.interface_config['IPV6_DEFAULTGW']).to eq(address)
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

  describe '#enable_dhcp6' do
    it 'sets the correct configuration' do
      [static_interface, dhcp_interface].each do |interface|
        interface.enable_dhcp6
        conf = interface.interface_config
        expect(conf).to include('IPV6INIT' => 'yes', 'DHCPV6C' => 'yes')
        expect(conf.keys).not_to include('IPV6ADDR', 'IPV6_DEFAULTGW')
      end
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

  describe '#apply_static6' do
    it 'sets the static IPv6 configuration' do
      expect(dhcp_interface).to receive(:save)
      dhcp_interface.apply_static6('d:e:a:d:b:e:e:f', 127, 'd:e:a:d::/64', ['d:e:a:d::'])
      conf = dhcp_interface.interface_config
      expect(conf).to include('IPV6INIT' => 'yes', 'DHCPV6C' => 'no', 'IPV6ADDR' => 'd:e:a:d:b:e:e:f/127', 'IPV6_DEFAULTGW' => 'd:e:a:d::/64')
    end
  end

  describe "#save" do
    let(:iface_file) { Pathname.new("/etc/sysconfig/network-scripts/ifcfg-#{device_name}") }

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
      expect(dhcp_interface).to receive(:stop).twice.and_return(false)
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
