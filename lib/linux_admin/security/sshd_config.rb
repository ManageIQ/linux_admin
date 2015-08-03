module LinuxAdmin
  class Security
    class SshdConfig
      require 'linux_admin/service'
      include Security::Common
      CONF_FILE = "/etc/ssh/sshd_config"

      SCAP_SETTINGS = {
        "PermitUserEnvironment" => "no",
        "PermitEmptyPasswords"  => "no",
        "Ciphers"               => "aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc",
        "ClientAliveInterval"   => "900",
        "ClientAliveCountMax"   => "0"
      }

      def apply_scap_settings(filename = CONF_FILE)
        config_text = File.read(filename)
        SCAP_SETTINGS.each do |k, v|
          new_line = "#{k} #{v}\n"
          config_text = replace_config_line(new_line, /^#*#{k}.*\n/, config_text)
        end
        File.write(filename, config_text)
      end
    end
  end
end
