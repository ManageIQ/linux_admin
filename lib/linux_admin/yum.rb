require 'fileutils'
require 'inifile'

module LinuxAdmin
  class Yum
    def self.create_repo(path, options = {})
      raise ArgumentError, "path is required" unless path
      options = {:database => true, :unique_file_names => true}.merge(options)

      FileUtils.mkdir_p(path)

      cmd    = "createrepo"
      params = {nil => path}
      params["--database"]            = nil  if options[:database]
      params["--unique-md-filenames"] = nil  if options[:unique_file_names]

      Common.run!(cmd, :params => params)
    end

    def self.download_packages(path, packages, options = {})
      raise ArgumentError, "path is required"       unless path
      raise ArgumentError, "packages are required"  unless packages
      options = {:mirror_type => :package}.merge(options)

      FileUtils.mkdir_p(path)

      cmd = case options[:mirror_type]
            when :package;  "repotrack"
            else;           raise ArgumentError, "mirror_type unsupported"
            end
      params = {"-p" => path}
      params["-a"]  = options[:arch] if options[:arch]
      params[nil]   = packages

      Common.run!(cmd, :params => params)
    end

    def self.repo_settings
      self.parse_repo_dir("/etc/yum.repos.d")
    end

    def self.updates_available?(*packages)
      cmd    = "yum check-update"
      params = {nil => packages} unless packages.blank?

      spawn = Common.run(cmd, :params => params)
      case spawn.exit_status
      when 0;   false
      when 100; true
      else raise "Error: #{cmd} returns '#{spawn.exit_status}', '#{spawn.error}'"
      end
    end

    def self.update(*packages)
      cmd    = "yum -y update"
      params = {nil => packages} unless packages.blank?

      out = Common.run!(cmd, :params => params)

      # Handle errors that exit 0  https://bugzilla.redhat.com/show_bug.cgi?id=1141318
      raise AwesomeSpawn::CommandResultError.new(out.error, out) if out.error.include?("No Match for argument")

      out
    end

    def self.version_available(*packages)
      raise ArgumentError, "packages requires at least one package name" if packages.blank?

      cmd    = "repoquery --qf=\"%{name} %{version}\""
      params = {nil => packages}

      out = Common.run!(cmd, :params => params).output

      out.split("\n").each_with_object({}) do |i, versions|
        name, version         = i.split(" ", 2)
        versions[name.strip]  = version.strip
      end
    end

    def self.repo_list(scope = "enabled")
      # Scopes could be "enabled", "all"

      cmd     = "yum repolist"
      params  = {nil => scope}
      output  = Common.run!(cmd, :params => params).output

      parse_repo_list_output(output)
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

    def self.parse_repo_list_output(content)
      collect_content = false
      index_start = "repo id"
      index_end   = "repolist:"

      content.split("\n").each_with_object([]) do |line, array|
        collect_content = false if line.start_with?(index_end)
        collect_content = true  if line.start_with?(index_start)
        next if line.start_with?(index_start)
        next if !collect_content

        repo_id, _repo_name, _status = line.split(/\s{2,}/)
        array.push(repo_id)
      end
    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "yum", "*.rb")).each { |f| require f }
