require 'ipaddr'

module LinuxAdmin
  class IpAddress
    def address
      address_list.detect { |ip| IPAddr.new(ip).ipv4? }
    end

    def address6
      address_list.detect { |ip| IPAddr.new(ip).ipv6? }
    end

    def mac_address(interface)
      result = Common.run(Common.cmd("ip"), :params => ["addr", "show", interface])
      return nil if result.failure?

      parse_output(result.output, %r{link/ether}, 1)
    end

    def netmask(interface)
      result = Common.run(Common.cmd("ifconfig"), :params => [interface])
      return nil if result.failure?

      parse_output(result.output, /netmask/, 3)
    end

    def gateway
      result = Common.run(Common.cmd("ip"), :params => ["route"])
      return nil if result.failure?

      parse_output(result.output, /^default/, 2)
    end

    private

    def parse_output(output, regex, col)
      the_line = output.split("\n").detect { |l| l =~ regex }
      the_line.nil? ? nil : the_line.strip.split(' ')[col]
    end

    def address_list
      result = nil
      # Added retry to account for slow DHCP not assigning an IP quickly at boot; specifically:
      # https://github.com/ManageIQ/manageiq-appliance/commit/160d8ccbfbfd617bdb5445e56cdab66b9323b15b
      5.times do
        result = Common.run(Common.cmd("hostname"), :params => ["-I"])
        break if result.success?
      end

      result.success? ? result.output.split(' ') : []
    end
  end
end
