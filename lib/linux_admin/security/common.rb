module LinuxAdmin
  class Security
    module Common
      def set_value(key, val, filename)
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
