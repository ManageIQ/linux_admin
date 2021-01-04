module LinuxAdmin
  class Service
    include Logging

    def self.service_type(reload = false)
      return @service_type if @service_type && !reload
      @service_type = service_type_uncached
    end

    class << self
      alias_method :orig_new, :new
      private :orig_new
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
      Common.cmd?(:systemctl) ? SystemdService : SysVInitService
    end
    private_class_method :service_type_uncached
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "service", "*.rb")).sort.each { |f| require f }
