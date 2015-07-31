module LinuxAdmin
  class Security
    class SysctlConf
      extend Security::Common
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
        config_text = File.read(filename)
        SCAP_SETTINGS.each do |k, v|
          new_line = "#{k} = #{v}\n"
          config_text = replace_config_line(new_line, /^[#;]*#{k}.*\n/, config_text)
        end
        File.write(filename, config_text)
      end
    end
  end
end
