require 'fileutils'
require 'inifile'

class LinuxAdmin
  class Yum < LinuxAdmin
    def self.create_repo(path, options={})
      raise ArgumentError, "path is required" unless path

      FileUtils.mkdir_p(sanitize({nil => path}))

      cmd    = "yum createrepo"
      params = {nil => path}
      params["--database"]            = nil  unless options[:no_database]
      params["--unique-md-filenames"] = nil  unless options[:no_unique_file_names]

      run(cmd, :params => params)
    end

    def self.download_packages(path, packages, options={:mirror_type => :package})
      raise ArgumentError, "path is required"       unless path
      raise ArgumentError, "packages are required"  unless packages

      FileUtils.mkdir_p(sanitize({nil => path}))

      cmd = case options[:mirror_type]
            when :package;  "yum repotrack"
            else;           raise ArgumentError, "mirror_type unsupported"
            end
      params = {"-p" => path}
      params["-a"]  = options[:arch] if options[:arch]
      params[nil]   = packages

      run(cmd, :params => params)
    end

    def self.repo_settings
      self.parse_repo_dir("/etc/yum.repos.d")
    end

    def self.updates_available?(*packages)
      cmd    = "yum check-update"
      params = {nil => packages} unless packages.blank?

      exitstatus = run(cmd, :params => params, :return_exitstatus => true)
      case exitstatus
      when 0;   false
      when 100; true
      else raise "Error: Exit Code #{exitstatus}"
      end
    end

    def self.update(*packages)
      cmd    = "yum -y update"
      params = {nil => packages} unless packages.blank?

      run(cmd, :params => params)
    end

    def self.version_available(*packages)
      raise ArgumentError, "packages requires at least one package name" unless packages

      cmd    = "repoquery --qf=\"%{name} %{version}\""
      params = {nil => packages}

      out = run(cmd, :params => params, :return_output => true)

      items = out.split("\n")
      items.each_with_object({}) do |i, versions|
        name, version = i.split(" ", 2)
        versions[name.strip] = version.strip
      end
    end

    private

    def self.parse_repo_dir(dir)
      repo_files = Dir.glob(File.join(dir, '*.repo'))
      repo_files.each_with_object({}) do |file, content|
        content[file] = self.parse_repo_file(file)
      end
    end

    def self.parse_repo_file(file)
      int_keys  = ["enabled", "cost", "gpgcheck", "sslverify", "metadata_expire"]
      content   = IniFile.load(file).to_h
      content.each do |name, data|
        int_keys.each { |k| data[k] = data[k].to_i if data.has_key?(k) }
      end
    end
  end
end