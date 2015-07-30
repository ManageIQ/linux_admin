module LinuxAdmin
  class Security
    class Modprobe
      CONF_FILE_NAME = "/etc/modprobe.d/scap_lockdown"
      SCAP_MODULES = %w(dccp sctp rds tipc)

      def self.apply_scap_settings(filename = CONF_FILE_NAME)
        SCAP_MODULES.each do |m|
          disable_module(m, filename)
        end
      end

      def self.disable_module(mod_name, filename)
        config_text = File.read(filename)
        new_line = "install #{mod_name} /bin/true"
        new_text = config_text.gsub!(/^install #{mod_name}.*/, new_line)

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

      def self.enable_module(mod_name, filename)
        config_text = File.read(filename)
        new_text = config_text.gsub!(/^install #{mod_name}.*/, "")

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
