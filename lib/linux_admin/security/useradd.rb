module LinuxAdmin
  class Security
    class Useradd
      CONF_FILE = "/etc/default/useradd"

      SCAP_SETTINGS = {
        "INACTIVE" => 35,
      }

      def self.apply_scap_settings(filename = CONF_FILE)
        SCAP_SETTINGS.each { |k, v| set_value(k, v, filename) }
      end

      def self.set_value(key, val, filename)
        config_text = File.read(filename)
        new_line = "#{key}=#{val}\n"
        new_text = config_text.gsub!(/^#*#{key}.*/, new_line)

        if new_text
          File.write(filename, new_text)
        else
          File.write(filename, new_line, :mode => "a")
        end
      end
    end
  end
end
