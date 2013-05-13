require 'fileutils'
require 'inifile'

module LinuxAdmin
  module Yum
    def self.create_repo(path, options={})
      raise ArgumentError, "path is required" unless path

      FileUtils.mkdir_p(LinuxAdmin::Common.sanitize(path))

      cmd = ["yum createrepo", path]
      cmd.push(" --database")             unless options[:no_database]
      cmd.push(" --unique-md-filenames")  unless options[:no_unique_file_names]
      Common.run(LinuxAdmin::Common.sanitize(cmd))
    end

    def self.download_packages(path, packages, options={:mirror_type => :package})
      raise ArgumentError, "path is required"       unless path
      raise ArgumentError, "packages are required"  unless packages

      FileUtils.mkdir_p(LinuxAdmin::Common.sanitize(path))

      cmd = case options[:mirror_type]
            when :package;  ["yum repotrack -p", path]
            else;           raise ArgumentError, "mirror_type unsupported"
            end
      cmd.push("-a", options[:arch]) if options[:arch]
      cmd.push(packages)
      Common.run(LinuxAdmin::Common.sanitize(cmd))
    end

    def self.repo_settings
      self.parse_repo_dir("/etc/yum.repos.d")
    end

    def self.updates_available?(*packages)
      cmd = ["yum check-update", packages]
      exitstatus = Common.run(LinuxAdmin::Common.sanitize(cmd), :return_exitstatus => true)
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

    private

    def self.parse_repo_dir(dir)
      repo_files = Dir.glob(File.join(dir, '*.repo'))
      repo_files.each_with_object({}) do |file, content|
        content[file] = self.parse_repo_file(file)
      end
    end

    def self.parse_repo_file(file)
      content = IniFile.load(file).to_h
      content.each do |name, data|
        data.each { |k, v|  data[k] = v.to_i if "enabled, cost, gpgcheck, sslverify, metadata_expire".include?(k)}
      end
    end
  end
end