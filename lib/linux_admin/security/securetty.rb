module LinuxAdmin
  class Security
    class Securetty
      CONF_FILE = "/etc/securetty"

      def self.remove_vcs(filename = CONF_FILE)
        config_text = File.read(filename)
        new_text = config_text.gsub!(%r{^vc/\d+\n}, "")

        if new_text
          File.open(filename, "w") do |file|
            file.puts(new_text)
          end
        end
      end
    end
  end
end
