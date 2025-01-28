describe LinuxAdmin::NetworkInterface do
  let(:device_name) { "eth0" }
  let(:config_file_path) { LinuxAdmin::NetworkInterfaceRH.path_to_interface_config_file(device_name) }
  context "on redhat systems" do
    describe ".dist_class" do
      it "returns NetworkInterfaceRH" do
        allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.rhel)
        expect(described_class.dist_class(true)).to eq(LinuxAdmin::NetworkInterfaceRH)
      end
    end

    describe ".new" do
      before do
        allow_any_instance_of(described_class).to receive(:ip_show).and_raise(LinuxAdmin::NetworkInterfaceError.new(nil, nil))
        allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.rhel)
        described_class.dist_class(true)
        allow(Pathname).to receive(:new).and_return(config_file_path)
      end

      it "creates a NetworkInterfaceRH instance if the config file does exist" do
        expect(config_file_path).to receive(:file?).and_return(true)
        expect(File).to receive(:foreach).and_return("")

        expect(described_class.new(device_name)).to be_an_instance_of(LinuxAdmin::NetworkInterfaceRH)
      end

      it "creates a NetworkInterfaceRH instance if the config file does not exist" do
        expect(config_file_path).to receive(:file?).and_return(false)

        expect(described_class.new(device_name)).to be_an_instance_of(LinuxAdmin::NetworkInterfaceRH)
      end
    end
  end

  context "on darwin systems" do
    describe ".dist_class" do
      it "returns NetworkInterfaceDarwin" do
        allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.darwin)
        expect(described_class.dist_class(true)).to eq(LinuxAdmin::NetworkInterfaceDarwin)
      end
    end

    describe ".new" do
      before do
        allow_any_instance_of(described_class).to receive(:ip_show).and_raise(LinuxAdmin::NetworkInterfaceError.new(nil, nil))
        allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.darwin)
        described_class.dist_class(true)
        allow(Pathname).to receive(:new).and_return(config_file_path)
      end

      it "creates a NetworkInterfaceDarwin instance" do
        expect(described_class.new(device_name)).to be_an_instance_of(LinuxAdmin::NetworkInterfaceDarwin)
      end
    end
  end

  context "on other linux systems" do
    describe ".dist_class" do
      it "returns NetworkInterfaceGeneric" do
        allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.generic)
        expect(described_class.dist_class(true)).to eq(LinuxAdmin::NetworkInterfaceGeneric)
      end
    end

    describe ".new" do
      subject do
        allow_any_instance_of(described_class).to receive(:ip_show).and_raise(LinuxAdmin::NetworkInterfaceError.new(nil, nil))
        allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.generic)
        described_class.dist_class(true)
        described_class.new(device_name)
      end

      it "creates a NetworkInterfaceGeneric instance" do
        expect(subject).to be_an_instance_of(LinuxAdmin::NetworkInterfaceGeneric)
      end
    end
  end

  context "on all systems" do
    let(:ip_link_args)      { [LinuxAdmin::Common.cmd("ip"),     {:params => %w[--json link]}] }
    let(:ip_show_eth0_args) { [LinuxAdmin::Common.cmd("ip"),     {:params => %w[--json addr show eth0]}] }
    let(:ip_show_lo_args)   { [LinuxAdmin::Common.cmd("ip"),     {:params => %w[--json addr show lo]}] }
    let(:ip_route_args)     { [LinuxAdmin::Common.cmd("ip"),     {:params => %w[--json -4 route show default]}] }
    let(:ip6_route_args)    { [LinuxAdmin::Common.cmd("ip"),     {:params => %w[--json -6 route show default]}] }
    let(:ifup_args)         { [LinuxAdmin::Common.cmd("ifup"),   {:params => ["eth0"]}] }
    let(:ifdown_args)       { [LinuxAdmin::Common.cmd("ifdown"), {:params => ["eth0"]}] }
    let(:ip_link_out) do
      <<~IP_OUT
        [{"ifindex":1,"ifname":"lo","flags":["LOOPBACK","UP","LOWER_UP"],"mtu":65536,"qdisc":"noqueue","operstate":"UNKNOWN","linkmode":"DEFAULT","group":"default","txqlen":1000,"link_type":"loopback","address":"00:00:00:00:00:00","broadcast":"00:00:00:00:00:00"},{"ifindex":2,"ifname":"eth0","flags":["BROADCAST","MULTICAST","UP","LOWER_UP"],"mtu":1500,"qdisc":"fq_codel","operstate":"UP","linkmode":"DEFAULT","group":"default","txqlen":1000,"link_type":"ether","address":"52:54:00:e8:67:81","broadcast":"ff:ff:ff:ff:ff:ff","altnames":["enp0s2","ens2"]}]
      IP_OUT
    end
    let(:ip_addr_eth0_out) do
      <<~IP_OUT
        [{"ifindex":2,"ifname":"eth0","flags":["BROADCAST","MULTICAST","UP","LOWER_UP"],"mtu":1500,"qdisc":"fq_codel","operstate":"UP","group":"default","txqlen":1000,"link_type":"ether","address":"00:0c:29:ed:0e:8b","broadcast":"ff:ff:ff:ff:ff:ff","altnames":["enp0s2","ens2"],"addr_info":[{"family":"inet","local":"192.168.1.9","prefixlen":24,"broadcast":"192.168.255","scope":"global","noprefixroute":true,"label":"eth0","valid_life_time":4294967295,"preferred_life_time":4294967295},{"family":"inet6","local":"fe80::20c:29ff:feed:e8b","prefixlen":64,"scope":"link","noprefixroute":true,"valid_life_time":"forever","preferred_life_time":"forever"},{"family":"inet6","local":"fd12:3456:789a:1::1","prefixlen":96,"scope":"global","noprefixroute":true,"valid_life_time":"forever","preferred_life_time":"forever"}]}]
      IP_OUT
    end
    let(:ip_addr_lo_out) do
      <<~IP_OUT
        [{"ifindex":1,"ifname":"lo","flags":["LOOPBACK","UP","LOWER_UP"],"mtu":65536,"qdisc":"noqueue","operstate":"UNKNOWN","group":"default","txqlen":1000,"link_type":"loopback","address":"00:00:00:00:00:00","broadcast":"00:00:00:00:00:00","addr_info":[{"family":"inet","local":"127.0.0.1","prefixlen":8,"scope":"host","label":"lo","valid_life_time":4294967295,"preferred_life_time":4294967295},{"family":"inet6","local":"::1","prefixlen":128,"scope":"host","valid_life_time":"forever","preferred_life_time":"forever"}]}]
      IP_OUT
    end
    let(:ip6_addr_out) do
      <<~IP_OUT
        [{"ifindex":2,"ifname":"eth0","flags":["BROADCAST","MULTICAST","UP","LOWER_UP"],"mtu":1500,"qdisc":"fq_codel","operstate":"UP","group":"default","txqlen":1000,"link_type":"ether","address":"00:0c:29:ed:0e:8b","broadcast":"ff:ff:ff:ff:ff:ff","altnames":["enp0s2","ens2"],"addr_info":[{"family":"inet6","local":"fe80::20c:29ff:feed:e8b","prefixlen":64,"scope":"link","noprefixroute":true,"valid_life_time":"forever","preferred_life_time":"forever"},{"family":"inet6","local":"fd12:3456:789a:1::1","prefixlen":96,"scope":"global","noprefixroute":true,"valid_life_time":"forever","preferred_life_time":"forever"}]}]
      IP_OUT
    end
    let(:ip_route_out) do
      <<~IP_OUT
        [{"dst":"default","gateway":"192.168.1.1","dev":"eth0","protocol":"static","metric":100,"flags":[]}]
      IP_OUT
    end
    let(:ip6_route_out) do
      <<~IP_OUT
        [{"dst":"default","gateway":"d:e:a:d:b:e:e:f","dev":"eth0","protocol":"static","metric":100,"flags":[]}]
      IP_OUT
    end
    let(:ip_none_addr_out) do
      <<~IP_OUT
        [{"ifindex":2,"ifname":"eth0","flags":["BROADCAST","MULTICAST","UP","LOWER_UP"],"mtu":1500,"qdisc":"fq_codel","operstate":"UP","group":"default","txqlen":1000,"link_type":"ether","address":"00:0c:29:ed:0e:8b","broadcast":"ff:ff:ff:ff:ff:ff","altnames":["enp0s2","ens2"],"addr_info":[]}]
      IP_OUT
    end

    subject(:subj_list) do
      allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.generic)
      described_class.dist_class(true)

      allow(AwesomeSpawn).to receive(:run!).with(*ip_link_args).and_return(result(ip_link_out, 0))
      allow(AwesomeSpawn).to receive(:run!).with(*ip_show_lo_args).and_return(result(ip_addr_lo_out, 0))
      allow(AwesomeSpawn).to receive(:run!).with(*ip_show_eth0_args).and_return(result(ip_addr_eth0_out, 0))
      allow(AwesomeSpawn).to receive(:run!).with(*ip_route_args).and_return(result(ip_route_out, 0))
      allow(AwesomeSpawn).to receive(:run!).with(*ip6_route_args).and_return(result(ip6_route_out, 0))
      described_class.list
    end

    subject(:subj) do
      allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.generic)
      described_class.dist_class(true)

      allow(AwesomeSpawn).to receive(:run!).with(*ip_show_eth0_args).and_return(result(ip_addr_eth0_out, 0))
      allow(AwesomeSpawn).to receive(:run!).with(*ip_route_args).and_return(result(ip_route_out, 0))
      allow(AwesomeSpawn).to receive(:run!).with(*ip6_route_args).and_return(result(ip6_route_out, 0))
      described_class.new(device_name)
    end

    subject(:subj6) do
      allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.generic)
      described_class.dist_class(true)

      allow(AwesomeSpawn).to receive(:run!).with(*ip_show_eth0_args).and_return(result(ip6_addr_out, 0))
      allow(AwesomeSpawn).to receive(:run!).with(*ip_route_args).and_return(result(ip_route_out, 0))
      allow(AwesomeSpawn).to receive(:run!).with(*ip6_route_args).and_return(result(ip6_route_out, 0))
      described_class.new(device_name)
    end

    subject(:subj_no_net) do
      allow(LinuxAdmin::Distros).to receive(:local).and_return(LinuxAdmin::Distros.generic)
      described_class.dist_class(true)

      allow(AwesomeSpawn).to receive(:run!).with(*ip_show_eth0_args).and_return(result(ip_none_addr_out, 0))
      allow(AwesomeSpawn).to receive(:run!).with(*ip_route_args).and_return(result(ip_route_out, 0))
      allow(AwesomeSpawn).to receive(:run!).with(*ip6_route_args).and_return(result(ip6_route_out, 0))
      described_class.new(device_name)
    end

    def result(output, exit_status)
      AwesomeSpawn::CommandResult.new("", output, "", nil, exit_status)
    end

    describe ".list" do
      it "returns a list of NetworkInterface objects" do
        interfaces = subj_list
        expect(interfaces.count).to eq(2)
        expect(interfaces.map(&:interface)).to match_array(["eth0", "lo"])
      end
    end

    describe "#reload" do
      it "returns false when ip addr show fails" do
        subj
        awesome_error = AwesomeSpawn::CommandResultError.new("", nil)
        allow(AwesomeSpawn).to receive(:run!).with(*ip_show_eth0_args).and_raise(awesome_error)
        expect(subj.reload).to eq(false)
      end

      it "raises when ip route fails" do
        subj
        awesome_error = AwesomeSpawn::CommandResultError.new("", nil)
        allow(AwesomeSpawn).to receive(:run!).with(*ip_show_eth0_args).and_return(result(ip_addr_eth0_out, 0))
        allow(AwesomeSpawn).to receive(:run!).with(*ip_route_args).and_raise(awesome_error)
        allow(AwesomeSpawn).to receive(:run!).with(*ip6_route_args).and_raise(awesome_error)
        expect { subj.reload }.to raise_error(LinuxAdmin::NetworkInterfaceError)
      end

      it "doesn't blow up when given only ipv6 addresses" do
        subj6
        allow(AwesomeSpawn).to receive(:run!).with(*ip_show_eth0_args).and_return(result(ip6_addr_out, 0))
        allow(AwesomeSpawn).to receive(:run!).with(*ip_route_args).and_return(result(ip_route_out, 0))
        allow(AwesomeSpawn).to receive(:run!).with(*ip6_route_args).and_return(result(ip6_route_out, 0))
        expect { subj.reload }.to_not raise_error
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

      it 'does not blow-up, when no ip assigned' do
        expect(subj_no_net.netmask).to eq(nil)
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

    describe '#prefix' do
      it 'returns the correct prefix' do
        expect(subj.prefix).to eq(24)
      end
    end

    describe '#prefix6' do
      it 'returns the correct global prefix length' do
        expect(subj.prefix6).to eq(96)
      end

      it 'returns the correct link local prefix length' do
        expect(subj.prefix6(:link)).to eq(64)
      end

      it 'raises ArgumentError when given a bad scope' do
        expect { subj.prefix6(:garbage) }.to raise_error(ArgumentError)
      end
    end

    describe "#gateway" do
      it "returns the correct gateway address" do
        expect(subj.gateway).to eq("192.168.1.1")
      end
    end

    describe '#gateway6' do
      it 'returns the correct default gateway for IPv6 routing' do
        expect(subj.gateway6).to eq('d:e:a:d:b:e:e:f')
      end
    end

    describe "#start" do
      it "returns true on success" do
        expect(AwesomeSpawn).to receive(:run).with(*ifup_args).and_return(result("", 0))
        expect(subj.start).to be true
      end

      it "returns false on failure" do
        expect(AwesomeSpawn).to receive(:run).with(*ifup_args).and_return(result("", 1))
        expect(subj.start).to be false
      end
    end

    describe "#stop" do
      it "returns true on success" do
        expect(AwesomeSpawn).to receive(:run).with(*ifdown_args).and_return(result("", 0))
        expect(subj.stop).to be true
      end

      it "returns false on failure" do
        expect(AwesomeSpawn).to receive(:run).with(*ifdown_args).and_return(result("", 1))
        expect(subj.stop).to be false
      end
    end
  end
end
