class LinuxAdmin
  class RegistrationSystem < LinuxAdmin
    def self.registration_type(reload = false)
      return @registration_type if @registration_type && !reload
      @registration_type = registration_type_uncached
    end

    def self.method_missing(meth, *args, &block)
      if white_list_methods.include?(meth)
        r = self.registration_type.new
        raise NotImplementedError, "#{meth} not implemented for #{self.name}" unless r.respond_to?(meth)
        r.send(meth, *args, &block)
      else
        super
      end
    end

    def registered?
      false
    end

    private

    def self.registration_type_uncached
      if SubscriptionManager.new.registered?
        SubscriptionManager
      elsif Rhn.new.registered?
        Rhn
      else
        self
      end
    end
    private_class_method :registration_type_uncached

    def self.white_list_methods
      @white_list_methods ||= begin
        all_methods = RegistrationSystem.instance_methods(false) + Rhn.instance_methods(false) + SubscriptionManager.instance_methods(false)
        all_methods.uniq
      end
    end
    private_class_method :white_list_methods
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "registration_system", "*.rb")).each { |f| require f }