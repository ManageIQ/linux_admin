module LinuxAdmin
  class Security
    class LoginDefs
      include Security::Common
      CONF_FILE = "/etc/login.defs"

      SCAP_SETTINGS = {
        "PASS_MIN_DAYS" => 1
      }

      def apply_scap_settings(filename = CONF_FILE)
        text = File.read(filename)
        SCAP_SETTINGS.each do |k, v|
          text = replace_config_line("#{k} #{v}\n", /^#*#{k}.*\n/, text)
        end
        File.write(filename, text)
      end
    end
  end
end
