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
      parse_conf
    end

    # Parses the interface configuration file into the @interface_conf hash
    def parse_conf
      @interface_conf = {}

      File.foreach(@interface_file) do |line|
        next if line =~ /^\s*#/

        key, value = line.split('=').collect(&:strip)
        @interface_conf[key] = value
      end
      @interface_conf["NM_CONTROLLED"] = "no"
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
      @interface_conf.delete("DNS1")
      @interface_conf.delete("DNS2")
      @interface_conf.delete("DOMAIN")
    end

    # Writes the contents of @interface_conf to @iface_file as `key`=`value` pairs
    # and resets the interface
    #
    # @return [Boolean] true if the interface was successfully brought up with the
    #   new configuration, false otherwise
    def save
      old_contents = File.read(@iface_file)

      return false unless stop

      File.write(@iface_file, @interface_conf.delete_blanks.collect { |k, v| "#{k}=#{v}" }.join("\n"))

      unless start
        File.write(@iface_file, old_contents)
        start
        return false
      end

      true
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
