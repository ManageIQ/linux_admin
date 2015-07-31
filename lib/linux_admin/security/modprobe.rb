module LinuxAdmin
  class Security
    class Modprobe
      CONF_FILE = "/etc/modprobe.d/scap_lockdown"
      SCAP_MODULES = %w(dccp sctp rds tipc)

      def self.apply_scap_settings(filename = CONF_FILE)
        SCAP_MODULES.each { |m| disable_module(m, filename) }
      end

      def self.disable_module(mod_name, filename)
        new_line = "install #{mod_name} /bin/true\n"
        begin
          config_text = File.read(filename)
          new_text = config_text.gsub!(/^install #{mod_name}.*/, new_line)
        rescue Errno::ENOENT
          # Okay if file doesn't exist we will create it
        end

        if new_text
          File.write(filename, new_text)
        else
          File.write(filename, new_line, :mode => "a")
        end
      end

      def self.enable_module(mod_name, filename)
        begin
          config_text = File.read(filename)
          new_text = config_text.gsub!(/^install #{mod_name}.*/, "")
        rescue Errno::ENOENT
          return
        end

        if new_text
          File.write(filename, new_text)
        else
          File.write(filename, new_line, :mode => "a")
        end
      end
    end
  end
end
