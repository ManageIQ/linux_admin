module LinuxAdmin
  class Security
    class Service
      require 'linux_admin/service'

      def self.apply_scap_settings
        disable_service("autofs")
        disable_service("atd")
      end

      def self.disable_service(service_name)
        serv = LinuxAdmin::Service.new(service_name)
        serv.stop if serv.running?
        serv.disable
      end
    end
  end
end
