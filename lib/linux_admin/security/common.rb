module LinuxAdmin
  class Security
    module Common
      def replace_config_line(new_line, rep_regex, file_text)
        new_text = file_text.gsub!(rep_regex, new_line)
        return new_text if new_text
        file_text << new_line
      end
    end
  end
end
