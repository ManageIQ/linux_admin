module LinuxAdmin
  class Homebrew < Package
    extend Logging
  
    def self.homebrew_cmd
      Common.cmd("brew")
    end

    def self.list_installed
      info(nil)
    end

    def self.info(pkg)
      out = Common.run!(homebrew_cmd, :params => ["list", :versions, pkg]).output
      out.split("\n").each_with_object({}) do |line, pkg_hash|
        name, ver = line.split(" ")[0..1] # only take the latest version
        pkg_hash[name] = ver
      end
    end
  end
end
  