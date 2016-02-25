module LinuxAdmin
  class Chrony
    def initialize(conf = "/etc/chrony.conf")
      raise MissingConfigurationFileError, "#{conf} does not exist" unless File.exist?(conf)
      @conf = conf
    end

    def clear_servers
      data = File.read(@conf)
      data.gsub!(/^server\s+.+\n/, "")
      File.write(@conf, data)
    end

    def add_servers(*servers)
      data = File.read(@conf)
      data << "\n" unless data.end_with?("\n")
      servers.each { |s| data << "server #{s} iburst\n" }
      File.write(@conf, data)
    end
  end
end
