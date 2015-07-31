module LinuxAdmin
  class Security
    class LimitsConf
      CONF_FILE = "/etc/security/limits.conf"

      def self.apply_scap_settings(filename = CONF_FILE)
        set_value("*", "hard", "core", 0, filename)
        set_value("*", "hard", "maxlogins", 10, filename)
      end

      def self.set_value(domain, type, item, value, filename = CONF_FILE)
        config_text = File.read(filename)
        new_line = "#{domain} #{type} #{item} #{value}\n"
        new_text = config_text.gsub!(/^[^#\n]* #{item} .*/, new_line)

        if new_text
          File.write(filename, new_text)
        else
          File.write(filename, new_line, :mode => "a")
        end
      end
    end
  end
end
