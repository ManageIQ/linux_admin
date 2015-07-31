module LinuxAdmin
  class Security
    class LimitsConf
      extend Security::Common
      CONF_FILE = "/etc/security/limits.conf"

      def self.apply_scap_settings(filename = CONF_FILE)
        config_text = File.read(filename)

        new_line = "* hard core 0\n"
        config_text = replace_config_line(new_line, /^[^#\n]* core .*\n/, config_text)

        new_line = "* hard maxlogins 10\n"
        config_text = replace_config_line(new_line, /^[^#\n]* maxlogins .*\n/, config_text)

        File.write(filename, config_text)
      end
    end
  end
end
