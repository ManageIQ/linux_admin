module LinuxAdmin
  class Security
    class SysctlConf
      CONF_FILE = "/etc/sysctl.conf"

      SCAP_SETTINGS = {
        "net.ipv4.conf.all.accept_redirects"         => 0,
        "net.ipv4.conf.all.secure_redirects"         => 0,
        "net.ipv4.conf.all.log_martians"             => 1,
        "net.ipv4.conf.default.secure_redirects"     => 0,
        "net.ipv4.conf.default.accept_redirects"     => 0,
        "net.ipv4.icmp_echo_ignore_broadcasts"       => 1,
        "net.ipv4.icmp_ignore_bogus_error_responses" => 1,
        "net.ipv4.conf.all.rp_filter"                => 1,
        "net.ipv6.conf.default.accept_redirects"     => 0,
        "net.ipv4.conf.default.send_redirects"       => 0,
        "net.ipv4.conf.all.send_redirects"           => 0
      }

      def self.apply_scap_settings(filename = CONF_FILE)
        SCAP_SETTINGS.each do |k, v|
          set_value(k, v, filename)
        end
      end

      def self.set_value(key, val, filename = CONF_FILE)
        config_text = File.read(filename)
        new_line = "#{key} = #{val}"
        new_text = config_text.gsub!(/^[#;]*#{key}.*/, new_line)

        if new_text
          File.open(filename, "w") do |file|
            file.puts(new_text)
          end
        else
          File.open(filename, "a") do |file|
            file.puts(new_line)
          end
        end
      end
    end
  end
end
