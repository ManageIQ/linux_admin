module LinuxAdmin
  class IpAddress
    include Common

    def address
      address_list.detect { |ip| IPAddr.new(ip).ipv4? }
    end

    def address6
      address_list.detect { |ip| IPAddr.new(ip).ipv6? }
    end

    def mac_address(interface)
      result = run(cmd("ip"), :params => ["addr", "show", interface])
      return nil if result.failure?

      lines = result.output.split("\n")
      link_line = lines.detect { |l| l =~ %r{link/ether} }
      link_line.nil? ? nil : link_line.strip.split(' ')[1]
    end

    private

    def address_list
      result = nil
      # Added retry to account for slow DHCP not assigning an IP quickly at boot; specifically:
      # https://github.com/ManageIQ/manageiq-appliance/commit/160d8ccbfbfd617bdb5445e56cdab66b9323b15b
      5.times do
        result = run(cmd("hostname"), :params => ["-I"])
        break if result.success?
      end

      result.success? ? result.output.split(' ') : []
    end
  end
end
