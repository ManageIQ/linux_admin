module LinuxAdmin
  class Rpm < Package
    extend Logging

    def self.rpm_cmd
      Common.cmd(:rpm)
    end

    def self.list_installed
      out = Common.run!("#{rpm_cmd} -qa --qf \"%{NAME} %{VERSION}-%{RELEASE}\n\"").output
      out.split("\n").each_with_object({}) do |line, pkg_hash|
        name, ver = line.split(" ")
        pkg_hash[name] = ver
      end
    end

    # Import a GPG file for use with RPM
    #
    #   Rpm.import_key("/etc/pki/my-gpg-key")
    def self.import_key(file)
      logger.info("#{self.class.name}##{__method__} Importing RPM-GPG-KEY: #{file}")
      Common.run!("rpm", :params => {"--import" => file})
    end

    def self.info(pkg)
      params = { "-qi" => pkg}
      in_description = false
      out = Common.run!(rpm_cmd, :params => params).output
      # older versions of rpm may have multiple fields per line,
      # split up lines with multiple tags/values:
      out.gsub!(/(^.*:.*)\s\s+(.*:.*)$/, "\\1\n\\2")
      out.split("\n").each.with_object({}) do |line, rpm|
        next if !line || line.empty?
        tag,value = line.split(':')
        tag = tag.strip
        if tag == 'Description'
          in_description = true
        elsif in_description
          rpm['description'] ||= ""
          rpm['description'] << line + " "
        else
          tag = tag.downcase.gsub(/\s/, '_')
          rpm[tag] = value.strip
        end
      end
    end

    def self.upgrade(pkg)
      cmd     = "rpm -U"
      params  = { nil => pkg }

      Common.run(cmd, :params => params).exit_status == 0
    end
  end
end
