module LinuxAdmin
  class Service
    extend Common
    include Common
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

    private

    def self.service_type_uncached
      cmd?(:systemctl) ? Systemctl : SysvService
    end
    private_class_method :service_type_uncached
  end
end
