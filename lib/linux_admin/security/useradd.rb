module LinuxAdmin
  class Security
    class Useradd
      extend Security::Common
      CONF_FILE = "/etc/default/useradd"

      SCAP_SETTINGS = {
        "INACTIVE" => 35,
      }

      def self.apply_scap_settings(filename = CONF_FILE)
        config_text = File.read(filename)
        SCAP_SETTINGS.each do |k, v|
          new_line = "#{k}=#{v}\n"
          config_text = replace_config_line(new_line, /^#*#{k}.*\n/, config_text)
        end
        File.write(filename, config_text)
      end
    end
  end
end
