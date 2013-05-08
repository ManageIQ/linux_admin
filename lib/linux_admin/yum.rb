module LinuxAdmin
  module Yum
    def self.create_repo(path, options={})
      Common.run("mkdir -p #{path}")

      create_cmd = "yum createrepo #{path}"
      create_cmd << " --database" unless options[:no_database]
      create_cmd << " --unique-md-filenames" unless options[:no_unique_file_names]
      Common.run(create_cmd)
    end

    def self.download_packages(path, package_string, options={})
      Common.run("mkdir -p #{path}")

      case options[:mirror_type]
      when :package; mirror_cmd = "yum repotrack -p #{path}"
      else; raise "mirror_type required"
      end
      mirror_cmd << " -a #{options[:arch]}" if options[:arch]
      mirror_cmd << " #{package_string}.strip"
      Common.run(mirror_cmd)
    end

    def self.updates_available?(*pkgs)
      cmd = "yum check-update"
      cmd << " #{pkgs.join(" ").strip}" unless pkgs.empty?
      exitstatus = Common.run(cmd, :return_exitstatus => true)
      case exitstatus
      when 0;   false
      when 100; true
      else raise "Error: Exit Code #{exitstatus}"
      end
    end

    def self.update(*packages)
      cmd = ["yum -y update", packages]
      Common.run(LinuxAdmin::Common.sanitize(cmd))
    end
  end
end