module LinuxAdmin
  class Security
    class Securetty
      include Security::Common
      CONF_FILE = "/etc/securetty"

      def apply_scap_settings(filename = CONF_FILE)
        remove_vcs(filename)
      end

      def remove_vcs(filename = CONF_FILE)
        config_text = File.read(filename)
        new_text = replace_config_line("", %r{^vc/\d+\n}, config_text)

        File.write(filename, new_text)
      end
    end
  end
end
