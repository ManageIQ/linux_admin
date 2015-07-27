module LinuxAdmin
  class Security
    class SshdConfig
      CONF_FILE = "/etc/ssh/sshd_config"

      SCAP_SETTINGS = {
        "PermitUserEnvironment" => "no",
        "PermitEmptyPasswords"  => "no",
        "Ciphers"               => "aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc",
        "ClientAliveInterval"   => "900",
        "ClientAliveCountMax"   => "0"
      }

      def self.apply_scap_settings(filename = CONF_FILE)
        SCAP_SETTINGS.each do |k, v|
          set_value(k, v, filename)
        end
      end

      def self.set_value(key, val, filename = CONF_FILE)
        config_text = File.read(filename)
        new_line = "#{key} #{val}"
        new_text = config_text.gsub!(/^#*#{key}.*/, new_line)

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
