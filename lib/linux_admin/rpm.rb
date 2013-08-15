class LinuxAdmin
  class Rpm < LinuxAdmin
    def self.list_installed
      out = run!("rpm -qa --qf \"%{NAME} %{VERSION}-%{RELEASE}\n\"").output
      out.split("\n").each_with_object({}) do |line, pkg_hash|
        name, ver = line.split(" ")
        pkg_hash[name] = ver
      end
    end
  end
end
