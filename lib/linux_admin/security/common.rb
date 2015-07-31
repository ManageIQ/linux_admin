module LinuxAdmin
  class Security
    module Common
      def set_value(key, val, filename)
        config_text = File.read(filename)
        new_line = "#{key} #{val}\n"
        new_text = config_text.gsub!(/^#*#{key}.*/, new_line)

        if new_text
          File.write(filename, new_text)
        else
          File.write(filename, new_line, :mode => "a")
        end
      end
    end
  end
end
