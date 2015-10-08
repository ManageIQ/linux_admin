require 'ipaddr'

module LinuxAdmin
  class NetworkInterface
    include Common

    # Cached class instance variable for what distro we are running on
    @dist_class = nil

    # Gets the subclass specific to the local Linux distro
    #
    # @param reload [Boolean] Determines if the cached value will be reloaded
    # @return [Class] The proper class to be used
    def self.dist_class(reload = false)
      @dist_class = nil if reload
      @dist_class ||= begin
        if [Distros.rhel, Distros.fedora].include?(Distros.local)
          NetworkInterfaceRH
        else
          NetworkInterfaceGeneric
        end
      end
    end

    class << self
      private

      alias_method :orig_new, :new
    end

    # Creates an instance of the correct NetworkInterface subclass for the local distro
    def self.new(*args)
      if self == LinuxAdmin::NetworkInterface
        dist_class.new(*args)
      else
        orig_new(*args)
      end
    end

    # @return [String] the interface for networking operations
    attr_reader :interface

    # @param interface [String] Name of the network interface to manage
    def initialize(interface)
      @interface = interface
    end

    # Retrieve the IPv4 address assigned to the interface
    #
    # @return [String] IPv4 address for the managed interface
    def address
      return unless (ip_output = ip_show)

      cidr_ip = parse_ip_output(ip_output, /inet/, 1)
      cidr_ip.split('/')[0] if cidr_ip
    end

    # Retrieve the IPv6 address assigned to the interface
    #
    # @return [String] IPv6 address for the managed interface
    def address6(scope = :global)
      return unless (ip_output = ip_show)

      ip_regex = /inet6 .* scope #{scope}/
      cidr_ip = parse_ip_output(ip_output, ip_regex, 1)
      cidr_ip.split('/')[0] if cidr_ip
    end

    # Retrieve the MAC address associated with the interface
    #
    # @return [String] the MAC address
    def mac_address
      return unless (ip_output = ip_show)
      parse_ip_output(ip_output, %r{link/ether}, 1)
    end

    # Retrieve the IPv4 sub-net mask assigned to the interface
    #
    # @return [String] IPv4 netmask
    def netmask
      return unless (ip_output = ip_show)

      cidr_ip = parse_ip_output(ip_output, /inet/, 1)
      IPAddr.new('255.255.255.255').mask(cidr_ip.split('/')[1]).to_s if cidr_ip
    end

    # Retrieve the IPv6 sub-net mask assigned to the interface
    #
    # @return [String] IPv6 netmask
    def netmask6(scope = :global)
      return unless (ip_output = ip_show)

      ip_regex = /inet6 .* scope #{scope}/
      cidr_ip = parse_ip_output(ip_output, ip_regex, 1)
      IPAddr.new('ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff').mask(cidr_ip.split('/')[1]).to_s if cidr_ip
    end

    # Retrieve the IPv4 default gateway associated with the interface
    #
    # @return [String] IPv4 gateway address
    def gateway
      result = run(cmd("ip"), :params => ["route"])
      return nil if result.failure?

      parse_ip_output(result.output, /^default/, 2)
    end

    private

    # Parses the output of `ip addr show`
    #
    # @param output [String] The command output
    # @param regex  [Regexp] Regular expression to match the desired output line
    # @param col    [Fixnum] The whitespace delimited column to be returned
    # @return [String] The parsed data
    def parse_ip_output(output, regex, col)
      the_line = output.split("\n").detect { |l| l =~ regex }
      the_line.nil? ? nil : the_line.strip.split(' ')[col]
    end

    # Runs the command `ip addr show <interface>`
    #
    # @return [String] The command output, nil on failure
    def ip_show
      result = run(cmd("ip"), :params => ["addr", "show", @interface])
      result.success? ? result.output : nil
    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "network_interface", "*.rb")).each { |f| require f }
