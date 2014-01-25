class LinuxAdmin
  class Rpm < Package
    RPM_CMD = '/usr/bin/rpm'

    def self.list_installed
      out = run!("rpm -qa --qf \"%{NAME} %{VERSION}-%{RELEASE}\n\"").output
      out.split("\n").each_with_object({}) do |line, pkg_hash|
        name, ver = line.split(" ")
        pkg_hash[name] = ver
      end
    end

    # Import a GPG file for use with RPM
    #
    #   Rpm.import_key("/etc/pki/my-gpg-key")
    def self.import_key(file)
      params = {"--import" => file}
      run!("rpm", :params => params)
    end

    def self.info(pkg)
      params = { "-qi" => pkg}
      in_description = false
      out = run!(RPM_CMD, :params => params).output
      out.split("\n").each.with_object({}) do |line, rpm|
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

      run(cmd, :params => params).exit_status == 0
    end
  end
end
