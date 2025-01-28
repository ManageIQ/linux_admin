module LinuxAdmin
  class NetworkInterfaceDarwin < NetworkInterface
    # Runs the command `ip -[4/6] route` and returns the output
    #
    # @param version [Fixnum] Version of IP protocol (4 or 6)
    # @return [String] The command output
    # @raise [NetworkInterfaceError] if the command fails
    #
    # macs use ip route get while others use ip route show
    def ip_route(version, route = "default")
      output = Common.run!(Common.cmd("ip"), :params => ["--json", "-#{version}", "route", "get", route]).output
      return {} if output.blank?

      JSON.parse(output).first
    rescue AwesomeSpawn::CommandResultError => e
      raise NetworkInterfaceError.new(e.message, e.result)
    end
  end
end
