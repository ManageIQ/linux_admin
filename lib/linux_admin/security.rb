module LinuxAdmin
  class Security
    require 'linux_admin/service'
    def scap_lockdown
      class_list = [SshdConfig, Service, SysctlConf, LimitsConf, Securetty, LoginDefs,
                    Useradd, AuditRules, Modprobe]
      class_list.each { |c| c.new.public_send(:apply_scap_settings) }
      AuditRules.new.reload_rules
      LinuxAdmin::Service.new("sshd").restart
    end
  end
end
require 'linux_admin/security/common'
Dir.glob(File.join(File.dirname(__FILE__), "security", "*.rb")).each { |f| require f }
