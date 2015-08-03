module LinuxAdmin
  class Security
    class AuditRules
      include LinuxAdmin::Common
      include Security::Common
      CONF_FILE = "/etc/audit/rules.d/audit.rules"

      SCAP_FILESYSTEM_RULES = [
        ["/etc/localtime",         "wa", "audit_time_rules"],
        ["/etc/group",             "wa", "audit_account_changes"],
        ["/etc/passwd",            "wa", "audit_account_changes"],
        ["/etc/gshadow",           "wa", "audit_account_changes"],
        ["/etc/shadow",            "wa", "audit_account_changes"],
        ["/etc/security/opasswd",  "wa", "audit_account_changes"],
        ["/etc/selinux/",          "wa", "MAC-policy"],
        ["/etc/sudoers",           "wa", "actions"],
        ["/sbin/insmod",           "x",  "modules"],
        ["/sbin/rmmod",            "x",  "modules"],
        ["/sbin/modprobe",         "x",  "modules"],
        ["/etc/issue",             "wa", "audit_network_modifications"],
        ["/etc/issue.net",         "wa", "audit_network_modifications"],
        ["/etc/hosts",             "wa", "audit_network_modifications"],
        ["/etc/sysconfig/network", "wa", "audit_network_modifications"]
      ]

      SCAP_SYSTEM_CALL_RULES = [
        [
          "always",
          "exit",
          %w(sethostname setdomainname),
          {"arch" => "b64"},
          "audit_network_modifications"
        ],
        [
          "always",
          "exit",
          %w(init_module delete_module),
          {"arch" => "b64"},
          "modules"
        ],
        [
          "always",
          "exit",
          %w(settimeofday clock_settime),
          {"arch" => "b64"},
          "audit_time_rules"
        ],
        [
          "always",
          "exit",
          ["adjtimex"],
          {"arch" => "b64"},
          "audit_time_rules"
        ],
        [
          "always",
          "exit",
          %w(creat open openat truncate ftruncate),
          {"arch" => "b64", "exit" => "-EACCES", "auid>" => "500", "auid!" => "4294967295"},
          "access"
        ],
        [
          "always",
          "exit",
          %w(creat open openat truncate ftruncate),
          {"arch" => "b64", "exit" => "-EPERM", "auid>" => "500", "auid!" => "4294967295"},
          "access"
        ]
      ]

      def apply_scap_settings(filename = CONF_FILE)
        set_buffer_size(16_384, filename)
        config_text = File.read(filename)

        SCAP_FILESYSTEM_RULES.each do |r|
          rule_text = filesystem_rule(*r)
          config_text = replace_config_line(rule_text, rule_text, config_text)
        end

        SCAP_SYSTEM_CALL_RULES.each do |r|
          rule_text = system_call_rule(*r)
          config_text = replace_config_line(rule_text, rule_text, config_text)
        end
        File.write(filename, config_text)
      end

      def filesystem_rule(path, permissions, key_name)
        rule = "-w #{path} -p #{permissions}"
        key_name ? rule << " -k #{key_name}\n" : rule << "\n"
      end

      def system_call_rule(action, filter, calls, fields, key_name)
        rule = "-a #{action},#{filter}"
        fields.each { |f, v| rule << " -F #{f}=#{v}" }
        calls.each { |c| rule << " -S #{c}" }
        key_name ? rule << " -k #{key_name}\n" : rule << "\n"
      end

      def set_buffer_size(size, filename = CONF_FILE)
        config_text = File.read(filename)
        new_line = "-b #{size}\n"
        new_text = replace_config_line(new_line, /^-b \d+\n/, config_text)

        File.write(filename, new_text)
      end

      def reload_rules(filename = CONF_FILE)
        run!(cmd(:auditctl), :params => {"-R" => [filename]})
      end
    end
  end
end