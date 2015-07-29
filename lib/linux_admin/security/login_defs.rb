module LinuxAdmin
  class Security
    class LoginDefs
      extend Security::Common
      CONF_FILE = "/etc/login.defs"

      SCAP_SETTINGS = {
        "PASS_MIN_DAYS" => 1
      }

      def self.apply_scap_settings(filename = CONF_FILE)
        SCAP_SETTINGS.each do |k, v|
          set_value(k, v, filename)
        end
      end
    end
  end
end
