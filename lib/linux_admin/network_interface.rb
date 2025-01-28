module LinuxAdmin
  class NetworkInterface
    require "ipaddr"
    require "json"

    # Cached class instance variable for what distro we are running on
    @dist_class = nil

    # Gets the subclass specific to the local Linux distro
    #
    # @param clear_cache [Boolean] Determines if the cached value will be reevaluated
    # @return [Class] The proper class to be used
    def self.dist_class(clear_cache = false)
      @dist_class = nil if clear_cache
      @dist_class ||= begin
        if [Distros.rhel, Distros.fedora].include?(Distros.local)
          NetworkInterfaceRH
        elsif Distros.local == Distros.darwin
          NetworkInterfaceDarwin
        else
          NetworkInterfaceGeneric
        end
      end
    end

    def self.list
      ip_link.pluck("ifname").map { |iface| new(iface) }
    rescue AwesomeSpawn::CommandResultError => e
      raise NetworkInterfaceError.new(e.message, e.result)
    end

    private_class_method def self.ip_link
      require "json"

      result = Common.run!(Common.cmd("ip"), :params => ["--json", "link"])
      JSON.parse(result.output)
    rescue AwesomeSpawn::CommandResultError, JSON::ParserError => e
      raise NetworkInterfaceError.new(e.message, e.result)
    end

    # Creates an instance of the correct NetworkInterface subclass for the local distro
    def self.new(*args)
      self == LinuxAdmin::NetworkInterface ? dist_class.new(*args) : super
    end

    # @return [String] the interface for networking operations
    attr_reader :interface, :link_type

    # @param interface [String] Name of the network interface to manage
    def initialize(interface)
      @interface = interface
      reload
    end

    # Gathers current network information for this interface
    #
    # @return [Boolean] true if network information was gathered successfully
    def reload
      @network_conf = {}
      begin
        ip_output = ip_show
      rescue NetworkInterfaceError
        return false
      end

      @link_type = ip_output["link_type"]
      addr_info  = ip_output["addr_info"]

      parse_ip4(addr_info)
      parse_ip6(addr_info, "global")
      parse_ip6(addr_info, "link")

      @network_conf[:mac] = ip_output["address"]

      [4, 6].each do |version|
        @network_conf["gateway#{version}".to_sym] = ip_route(version, "default")&.dig("gateway")
      end
      true
    end

    def loopback?
      @link_type == "loopback"
    end

    # Retrieve the IPv4 address assigned to the interface
    #
    # @return [String] IPv4 address for the managed interface
    def address
      @network_conf[:address]
    end

    # Retrieve the IPv6 address assigned to the interface
    #
    # @return [String] IPv6 address for the managed interface
    # @raise [ArgumentError] if the given scope is not `:global` or `:link`
    def address6(scope = :global)
      case scope
      when :global
        @network_conf[:address6_global]
      when :link
        @network_conf[:address6_link]
      else
        raise ArgumentError, "Unrecognized address scope #{scope}"
      end
    end

    # Retrieve the MAC address associated with the interface
    #
    # @return [String] the MAC address
    def mac_address
      @network_conf[:mac]
    end

    # Retrieve the IPv4 sub-net mask assigned to the interface
    #
    # @return [String] IPv4 netmask
    def netmask
      @network_conf[:mask] ||= IPAddr.new('255.255.255.255').mask(prefix).to_s if prefix
    end

    # Retrieve the IPv6 sub-net mask assigned to the interface
    #
    # @return [String] IPv6 netmask
    # @raise [ArgumentError] if the given scope is not `:global` or `:link`
    def netmask6(scope = :global)
      if [:global, :link].include?(scope)
        @network_conf["mask6_#{scope}".to_sym] ||= IPAddr.new('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff').mask(prefix6(scope)).to_s if prefix6(scope)
      else
        raise ArgumentError, "Unrecognized address scope #{scope}"
      end
    end

    # Retrieve the IPv4 sub-net prefix length assigned to the interface
    #
    # @return [Numeric] IPv4 prefix length
    def prefix
      @network_conf[:prefix]
    end

    # Retrieve the IPv6 sub-net prefix length assigned to the interface
    #
    # @return [Numeric] IPv6 prefix length
    def prefix6(scope = :global)
      if [:global, :link].include?(scope)
        @network_conf["prefix6_#{scope}".to_sym]
      else
        raise ArgumentError, "Unrecognized address scope #{scope}"
      end
    end

    # Retrieve the IPv4 default gateway associated with the interface
    #
    # @return [String] IPv4 gateway address
    def gateway
      @network_conf[:gateway4]
    end

    # Retrieve the IPv6 default gateway associated with the interface
    #
    # @return [String] IPv6 gateway address
    def gateway6
      @network_conf[:gateway6]
    end

    # Brings up the network interface
    #
    # @return [Boolean] whether the command succeeded or not
    def start
      Common.run(Common.cmd("ifup"), :params => [@interface]).success?
    end

    # Brings down the network interface
    #
    # @return [Boolean] whether the command succeeded or not
    def stop
      Common.run(Common.cmd("ifdown"), :params => [@interface]).success?
    end

    private

    # Runs the command `ip addr show <interface>`
    #
    # @return [String] The command output
    # @raise [NetworkInterfaceError] if the command fails
    def ip_show
      output = Common.run!(Common.cmd("ip"), :params => ["--json", "addr", "show", @interface]).output
      return {} if output.blank?

      JSON.parse(output).first
    rescue AwesomeSpawn::CommandResultError => e
      raise NetworkInterfaceError.new(e.message, e.result)
    end

    # Runs the command `ip -[4/6] route` and returns the output
    #
    # @param version [Fixnum] Version of IP protocol (4 or 6)
    # @return [String] The command output
    # @raise [NetworkInterfaceError] if the command fails
    def ip_route(version, route = "default")
      output = Common.run!(Common.cmd("ip"), :params => ["--json", "-#{version}", "route", "show", route]).output
      return {} if output.blank?

      JSON.parse(output).first
    rescue AwesomeSpawn::CommandResultError => e
      raise NetworkInterfaceError.new(e.message, e.result)
    end

    # Parses the IPv4 information from the output of `ip addr show <device>`
    #
    # @param ip_output [String] The command output
    def parse_ip4(addr_info)
      inet = addr_info&.detect { |addr| addr["family"] == "inet" }
      return if inet.nil?

      @network_conf[:address] = inet["local"]
      @network_conf[:prefix]  = inet["prefixlen"]
    end

    # Parses the IPv6 information from the output of `ip addr show <device>`
    #
    # @param ip_output [String] The command output
    # @param scope     [Symbol] The IPv6 scope (either `:global` or `:local`)
    def parse_ip6(addr_info, scope)
      inet6 = addr_info&.detect { |addr| addr["family"] == "inet6" && addr["scope"] == scope }
      return if inet6.nil?

      @network_conf["address6_#{scope}".to_sym] = inet6["local"]
      @network_conf["prefix6_#{scope}".to_sym]  = inet6["prefixlen"]
    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "network_interface", "*.rb")).each { |f| require f }
