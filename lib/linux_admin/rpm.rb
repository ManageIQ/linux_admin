class LinuxAdmin
  class Rpm < LinuxAdmin
    def self.list_installed
      raw = run("rpm -qa --qf \"%{NAME},%{VERSION}-%{RELEASE}\n\"", :return_output => true)
      raw.split("\n").each_with_object({}) do |line, pkg_hash|
        name, ver = line.split(",")
        pkg_hash[name] = ver
      end
    end
  end
end