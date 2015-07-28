module LinuxAdmin
  class Security
    def self.scap_lockdown
      SshdConfig.apply_scap_settings
      Service.apply_scap_settings
      SysctlConf.apply_scap_settings
    end
  end
end
Dir.glob(File.join(File.dirname(__FILE__), "security", "*.rb")).each { |f| require f }
