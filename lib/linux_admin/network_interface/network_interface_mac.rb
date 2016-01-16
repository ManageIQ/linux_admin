require 'socket'

module LinuxAdmin
  class NetworkInterfaceMac < NetworkInterface
    # Determine the ip address of a ipv4 (non loopback) interface
    # NOTE: currently ignores the interface name
    #
    # @return [String] The command output
    # @raise [NetworkInterfaceError] if the command fails
    def ip_show
      socket = Socket.ip_address_list.detect { |intf| intf.ipv4? && !intf.ipv4_loopback? }
      if socket
        socket.ip_address
      else
        raise NetworkInterfaceError.new("could not find ipv4 interface", 4)
      end
    end

    # Determine the Runs the command `ip route`
    #
    # @return [String] The command output
    # @raise [NetworkInterfaceError] if the command fails
    def ip_route
      gateway = run!(cmd("route"), :params => %w(-n get default)).output
                .split("\n").detect { |l| l =~ /gateway/ }.split(":").last.strip
      "default via #{gateway} dev #{@interface}"
    rescue AwesomeSpawn::CommandResultError => e
      raise NetworkInterfaceError.new(e.message, e.result)
    end

    def parse_conf
      # currently a noop
    end
  end
end
