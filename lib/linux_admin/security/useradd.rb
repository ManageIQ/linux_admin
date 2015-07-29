module LinuxAdmin
  class Security
    class Useradd
      CONF_FILE = "/etc/default/useradd"

      SCAP_SETTINGS = {
        "INACTIVE" => 35,
      }

      def self.apply_scap_settings(filename = CONF_FILE)
        SCAP_SETTINGS.each do |k, v|
          set_value(k, v, filename)
        end
      end

      def self.set_value(key, val, filename)
        config_text = File.read(filename)
        new_line = "#{key}=#{val}"
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
