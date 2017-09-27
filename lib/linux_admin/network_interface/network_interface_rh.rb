require 'ipaddr'
require 'pathname'

module LinuxAdmin
  class NetworkInterfaceRH < NetworkInterface
    IFACE_DIR = "/etc/sysconfig/network-scripts"

    # @return [Hash<String, String>] Key value mappings in the interface file
    attr_reader :interface_config

    # @param interface [String] Name of the network interface to manage
    def initialize(interface)
      @interface_file = self.class.path_to_interface_config_file(interface)
      super
      parse_conf
    end

    # Parses the interface configuration file into the @interface_config hash
    def parse_conf
      @interface_config = {}

      if @interface_file.file?
        File.foreach(@interface_file) do |line|
          next if line =~ /^\s*#/

          key, value = line.split('=').collect(&:strip)
          @interface_config[key] = value
        end
      end

      @interface_config["NM_CONTROLLED"] = "no"
    end

    # Set the IPv4 address for this interface
    #
    # @param address [String]
    # @raise ArgumentError if the address is not formatted properly
    def address=(address)
      validate_ip(address)
      @interface_config["BOOTPROTO"] = "static"
      @interface_config["IPADDR"]    = address
    end

    # Set the IPv6 address for this interface
    #
    # @param address [String] IPv6 address including the prefix length (i.e. '::1/127')
    # @raise ArgumentError if the address is not formatted properly
    def address6=(address)
      validate_ip(address)
      @interface_config['IPV6INIT']  = 'yes'
      @interface_config['DHCPV6C']   = 'no'
      @interface_config['IPV6ADDR']  = address
    end

    # Set the IPv4 gateway address for this interface
    #
    # @param address [String]
    # @raise ArgumentError if the address is not formatted properly
    def gateway=(address)
      validate_ip(address)
      @interface_config["GATEWAY"] = address
    end

    # Set the IPv6 gateway address for this interface
    #
    # @param address [String] IPv6 address optionally including the prefix length
    # @raise ArgumentError if the address is not formatted properly
    def gateway6=(address)
      validate_ip(address)
      @interface_config['IPV6_DEFAULTGW'] = address
    end

    # Set the IPv4 sub-net mask for this interface
    #
    # @param mask [String]
    # @raise ArgumentError if the mask is not formatted properly
    def netmask=(mask)
      validate_ip(mask)
      @interface_config["NETMASK"] = mask
    end

    # Sets one or both DNS servers for this network interface
    #
    # @param servers [Array<String>] The DNS servers
    def dns=(*servers)
      server1, server2 = servers.flatten
      @interface_config["DNS1"] = server1
      @interface_config["DNS2"] = server2 if server2
    end

    # Sets the search domain list for this network interface
    #
    # @param domains [Array<String>] the list of search domains
    def search_order=(*domains)
      @interface_config["DOMAIN"] = "\"#{domains.flatten.join(' ')}\""
    end

    # Set up the interface to use DHCP
    # Removes any previously set static IPv4 networking information
    def enable_dhcp
      @interface_config["BOOTPROTO"] = "dhcp"
      @interface_config.delete("IPADDR")
      @interface_config.delete("NETMASK")
      @interface_config.delete("GATEWAY")
      @interface_config.delete("PREFIX")
      @interface_config.delete("DNS1")
      @interface_config.delete("DNS2")
      @interface_config.delete("DOMAIN")
    end

    # Set up the interface to use DHCPv6
    # Removes any previously set static IPv6 networking information
    def enable_dhcp6
      @interface_config['IPV6INIT'] = 'yes'
      @interface_config['DHCPV6C'] = 'yes'
      @interface_config.delete('IPV6ADDR')
      @interface_config.delete('IPV6_DEFAULTGW')
      @interface_config.delete("DNS1")
      @interface_config.delete("DNS2")
      @interface_config.delete("DOMAIN")
    end

    # Applies the given static network configuration to the interface
    #
    # @param ip [String] IPv4 address
    # @param mask [String] subnet mask
    # @param gw [String] gateway address
    # @param dns [Array<String>] list of dns servers
    # @param search [Array<String>] list of search domains
    # @return [Boolean] true on success, false otherwise
    # @raise ArgumentError if an IP is not formatted properly
    def apply_static(ip, mask, gw, dns, search = nil)
      self.address      = ip
      self.netmask      = mask
      self.gateway      = gw
      self.dns          = dns
      self.search_order = search if search
      save
    end

    # Applies the given static IPv6 network configuration to the interface
    #
    # @param ip [String] IPv6 address
    # @param prefix [Number] prefix length for IPv6 address
    # @param gw [String] gateway address
    # @param dns [Array<String>] list of dns servers
    # @param search [Array<String>] list of search domains
    # @return [Boolean] true on success, false otherwise
    # @raise ArgumentError if an IP is not formatted properly or interface does not start
    def apply_static6(ip, prefix, gw, dns, search = nil)
      self.address6     = "#{ip}/#{prefix}"
      self.gateway6     = gw
      self.dns          = dns
      self.search_order = search if search
      save
    end

    # Writes the contents of @interface_config to @interface_file as `key`=`value` pairs
    # and resets the interface
    #
    # @return [Boolean] true if the interface was successfully brought up with the
    #   new configuration, false otherwise
    def save
      old_contents = @interface_file.file? ? File.read(@interface_file) : ""

      stop_success = stop
      # Stop twice because when configure both ipv4 and ipv6 as dhcp, ipv6 dhcp client will
      # exit and leave a /var/run/dhclient6-eth0.pid file. Then stop (ifdown eth0) will try
      # to kill this exited process so it returns 1. In the second call, this `.pid' file
      # has been deleted and ifdown returns 0.
      # See: https://bugzilla.redhat.com/show_bug.cgi?id=1472396
      stop_success = stop unless stop_success
      return false unless stop_success

      File.write(@interface_file, @interface_config.delete_blanks.collect { |k, v| "#{k}=#{v}" }.join("\n"))

      unless start
        File.write(@interface_file, old_contents)
        start
        return false
      end

      reload
    end

    def self.path_to_interface_config_file(interface)
      Pathname.new(IFACE_DIR).join("ifcfg-#{interface}")
    end

    private

    # Validate that the given address is formatted correctly
    #
    # @param ip [String]
    # @raise ArgumentError if the address is not correctly formatted
    def validate_ip(ip)
      IPAddr.new(ip)
    rescue ArgumentError
      raise ArgumentError, "#{ip} is not a valid IPv4 or IPv6 address"
    end
  end
end
