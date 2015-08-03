module LinuxAdmin
  class Security
    class Modprobe
      include Security::Common
      CONF_FILE = "/etc/modprobe.d/scap.conf"
      SCAP_MODULES = %w(dccp sctp rds tipc)

      def apply_scap_settings(filename = CONF_FILE)
        SCAP_MODULES.each { |m| disable_module(m, filename) }
      end

      def disable_module(mod_name, filename)
        begin
          config_text = File.read(filename)
        rescue Errno::ENOENT
          # Okay if file doesn't exist we will create it
          config_text = ""
        end

        new_line = "install #{mod_name} /bin/true\n"
        new_text = replace_config_line(new_line, /^install #{mod_name}.*\n/, config_text)
        File.write(filename, new_text)
      end

      def enable_module(mod_name, filename)
        begin
          config_text = File.read(filename)
        rescue Errno::ENOENT
          return
        end

        new_text = replace_config_line("", /^install #{mod_name}.*\n/, config_text)
        File.write(filename, new_text)
      end
    end
  end
end
