module LinuxAdmin
  class Chrony
    SERVICE_NAME = "chronyd".freeze

    def initialize(conf = "/etc/chrony.conf")
      raise MissingConfigurationFileError, "#{conf} does not exist" unless File.exist?(conf)
      @conf = conf
    end

    def clear_servers
      data = File.read(@conf)
      data.gsub!(/^server\s+.+\n/, "")
      data.gsub!(/^pool\s+.+\n/, "")
      File.write(@conf, data)
    end

    def add_servers(*servers)
      data = File.read(@conf)
      data << "\n" unless data.end_with?("\n")
      servers.each { |s| data << "server #{s} iburst\n" }
      File.write(@conf, data)
      restart_service_if_running
    end

    private

    def restart_service_if_running
      service = Service.new(SERVICE_NAME)
      service.restart if service.running?
    end
  end
end
