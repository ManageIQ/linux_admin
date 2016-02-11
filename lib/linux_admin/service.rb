module LinuxAdmin
  class Service
    include Logging

    def self.service_type(reload = false)
      return @service_type if @service_type && !reload
      @service_type = service_type_uncached
    end

    class << self
      private
      alias_method :orig_new, :new
    end

    def self.new(*args)
      if self == LinuxAdmin::Service
        service_type.new(*args)
      else
        orig_new(*args)
      end
    end

    attr_accessor :name

    def initialize(name)
      @name = name
    end

    alias_method :id, :name
    alias_method :id=, :name=

    private

    def self.service_type_uncached
      {
        :systemctl => SystemdService,
        :service   => SysVInitService,
        :brew      => BrewService,
      }.each do |key, service|
        return service if Common.cmd?(key)
      end
      nil
    end
    private_class_method :service_type_uncached
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "service", "*.rb")).each { |f| require f }
