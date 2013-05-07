module LinuxAdmin
  module Yum
    def self.create_repo(path, options={})
      Common.run("mkdir -p #{path}")

      create_cmd = "yum createrepo #{path}"
      create_cmd << " --database" unless options[:no_database]
      create_cmd << " --unique-md-filenames" unless options[:no_unique_file_names]
      Common.run(create_cmd)
    end

    def self.updates_available?
      exitstatus = Common.run("yum check-update", :return_exitstatus => true)
      case exitstatus
      when 0;   false
      when 100; true
      else raise "Error: Exit Code #{exitstatus}"
      end
    end

    def self.update
      Common.run("yum -y update")
    end
  end
end