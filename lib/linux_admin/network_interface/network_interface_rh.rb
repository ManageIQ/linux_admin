require 'ipaddr'
require 'pathname'

module LinuxAdmin
  class NetworkInterfaceRH < NetworkInterface
    IFACE_DIR = "/etc/sysconfig/network-scripts"

    # @return [Hash<String, String>] Key value mappings in the interface file
    attr_reader :interface_conf

    # @param interface [String] Name of the network interface to manage
    def initialize(interface)
      super
      @iface_file = Pathname.new(IFACE_DIR).join("ifcfg-#{@interface}")
      reload
    end

    # Parses the interface configuration file into the @interface_conf hash
    def reload
      @interface_conf = {"NM_CONTROLLED" => "no"}
      contents = File.read(@iface_file)

      contents.each_line do |line|
        next if line =~ /^\s*#/

        pair = line.split('=').collect(&:strip)
        @interface_conf[pair[0]] = pair[1]
      end
    end

    # Set the IPv4 address for this interface
    #
    # @param address [String]
    # @raise ArgumentError if the address is not formatted properly
    def address=(address)
      validate_ip(address)
      @interface_conf["BOOTPROTO"] = "static"
      @interface_conf["IPADDR"]    = address
    end

    # Set the IPv4 gateway address for this interface
    #
    # @param address [String]
    # @raise ArgumentError if the address is not formatted properly
    def gateway=(address)
      validate_ip(address)
      @interface_conf["GATEWAY"] = address
    end

    # Set the IPv4 sub-net mask for this interface
    #
    # @param mask [String]
    # @raise ArgumentError if the mask is not formatted properly
    def netmask=(mask)
      validate_ip(mask)
      @interface_conf["NETMASK"] = mask
    end

    # Sets one or both DNS servers for this network interface
    #
    # @param servers [Array<String>] The DNS servers
    def dns=(*servers)
      server1, server2 = servers.flatten
      @interface_conf["DNS1"] = server1
      @interface_conf["DNS2"] = server2 if server2
    end

    # Sets the search domain list for this network interface
    #
    # @param domains [Array<String>] the list of search domains
    def search_order=(*domains)
      @interface_conf["DOMAIN"] = "\"#{domains.flatten.join(' ')}\""
    end

    # Set up the interface to use DHCP
    # Removes any previously set static networking information
    def enable_dhcp
      @interface_conf["BOOTPROTO"] = "dhcp"
      @interface_conf.delete("IPADDR")
      @interface_conf.delete("NETMASK")
      @interface_conf.delete("GATEWAY")
      @interface_conf.delete("PREFIX")
    end

    # Writes the contents of @interface_conf to @iface_file as `key`=`value` pairs
    def save
      File.write(@iface_file, @interface_conf.delete_blanks.collect { |k, v| "#{k}=#{v}" }.join("\n"))
    end

    private

    # Validate that the given address is formatted correctly
    #
    # @param ip [String]
    # @raise ArgumentError if the address is not correctly formatted
    def validate_ip(ip)
      IPAddr.new(ip)
    rescue IPAddr::InvalidAddressError
      raise ArgumentError, "#{ip} is not a valid IPv4 or IPv6 address"
    end
  end
end
