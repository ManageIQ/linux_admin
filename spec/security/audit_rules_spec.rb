describe LinuxAdmin::Security::AuditRules do
  def test_file_name
    File.join(data_file_path("security"), "audit.rules")
  end

  def test_file_contents
    File.read(test_file_name)
  end

  around(:each) do |example|
    text = test_file_contents
    example.run
    File.write(test_file_name, text)
  end

  describe ".apply_scap_settings" do
    it "sets the buffer size" do
      described_class.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^-b 16384\n/)
    end

    it "sets filesystem audit_time_rules rules" do
      described_class.apply_scap_settings(test_file_name)

      pat = %r{^-w /etc/localtime -p wa -k audit_time_rules\n}
      expect(test_file_contents).to match(pat)
    end

    it "sets filesystem audit_account_changes rules" do
      described_class.apply_scap_settings(test_file_name)

      pat = %r{^-w /etc/group -p wa -k audit_account_changes\n}
      expect(test_file_contents).to match(pat)
      pat = %r{^-w /etc/passwd -p wa -k audit_account_changes\n}
      expect(test_file_contents).to match(pat)
      pat = %r{^-w /etc/gshadow -p wa -k audit_account_changes\n}
      expect(test_file_contents).to match(pat)
      pat = %r{^-w /etc/shadow -p wa -k audit_account_changes\n}
      expect(test_file_contents).to match(pat)
      pat = %r{^-w /etc/security/opasswd -p wa -k audit_account_changes\n}
      expect(test_file_contents).to match(pat)
    end

    it "sets filesystem MAC-policy rules" do
      described_class.apply_scap_settings(test_file_name)

      pat = %r{^-w /etc/selinux/ -p wa -k MAC-policy\n}
      expect(test_file_contents).to match(pat)
    end

    it "sets filesystem actions rules" do
      described_class.apply_scap_settings(test_file_name)

      pat = %r{^-w /etc/sudoers -p wa -k actions\n}
      expect(test_file_contents).to match(pat)
    end

    it "sets filesystem modules rules" do
      described_class.apply_scap_settings(test_file_name)

      pat = %r{^-w /sbin/insmod -p x -k modules\n}
      expect(test_file_contents).to match(pat)
      pat = %r{^-w /sbin/rmmod -p x -k modules\n}
      expect(test_file_contents).to match(pat)
      pat = %r{^-w /sbin/modprobe -p x -k modules\n}
      expect(test_file_contents).to match(pat)
    end

    it "sets filesystem audit_network_modifications rules" do
      described_class.apply_scap_settings(test_file_name)

      pat = %r{^-w /etc/issue -p wa -k audit_network_modifications\n}
      expect(test_file_contents).to match(pat)
      pat = %r{^-w /etc/issue.net -p wa -k audit_network_modifications\n}
      expect(test_file_contents).to match(pat)
      pat = %r{^-w /etc/hosts -p wa -k audit_network_modifications\n}
      expect(test_file_contents).to match(pat)
      pat = %r{^-w /etc/sysconfig/network -p wa -k audit_network_modifications\n}
      expect(test_file_contents).to match(pat)
    end

    it "sets system call audit_network_modifications rules" do
      described_class.apply_scap_settings(test_file_name)

      pat = /^-a always,exit -F arch=b64 -S sethostname -S setdomainname -k audit_network_modifications\n/
      expect(test_file_contents).to match(pat)
    end

    it "sets system call modules rules" do
      described_class.apply_scap_settings(test_file_name)

      pat = /^-a always,exit -F arch=b64 -S init_module -S delete_module -k modules\n/
      expect(test_file_contents).to match(pat)
    end

    it "sets system call audit_time_rules rules" do
      described_class.apply_scap_settings(test_file_name)

      pat = /^-a always,exit -F arch=b64 -S settimeofday -S clock_settime -k audit_time_rules\n/
      expect(test_file_contents).to match(pat)
      pat = /^-a always,exit -F arch=b64 -S adjtimex -k audit_time_rules\n/
      expect(test_file_contents).to match(pat)
    end

    it "sets system call access rules" do
      described_class.apply_scap_settings(test_file_name)

      pat = /^-a\salways,exit\s-F\sarch=b64\s-F\sexit=-EACCES\s-F\sauid>=500\s
             -F\sauid!=4294967295\s-S\screat\s-S\sopen\s-S\sopenat\s-S\s
             truncate\s-S\sftruncate\s-k\saccess\n/x
      expect(test_file_contents).to match(pat)
      pat = /^-a\salways,exit\s-F\sarch=b64\s-F\sexit=-EPERM\s-F\sauid>=500\s
             -F\sauid!=4294967295\s-S\screat\s-S\sopen\s-S\sopenat\s-S\s
             truncate\s-S\sftruncate\s-k\saccess\n/x
      expect(test_file_contents).to match(pat)
    end
  end

  describe ".add_filesystem_rule" do
    it "adds a correctly formated rule" do
      args = ["/etc/localtime", "wa", "audit_time_rules"]
      described_class.add_filesystem_rule(*args, test_file_name)
      pat = %r{^-w /etc/localtime -p wa -k audit_time_rules\n}
      expect(test_file_contents).to match(pat)
    end

    it "adds a rule without a key" do
      args = ["/etc/localtime", "wa", nil]
      described_class.add_filesystem_rule(*args, test_file_name)
      expect(test_file_contents).to match(%r{^-w /etc/localtime -p wa\n})
    end
  end

  describe ".add_system_call_rule" do
    it "adds a correctly formated rule" do
      args = [
        "always",
        "exit",
        ["adjtimex"],
        {"arch" => "b64"},
        "audit_time_rules"
      ]
      described_class.add_system_call_rule(*args, test_file_name)
      pat = /^-a always,exit -F arch=b64 -S adjtimex -k audit_time_rules\n/
      expect(test_file_contents).to match(pat)
    end

    it "adds a rule without a key" do
      args = [
        "always",
        "exit",
        ["adjtimex"],
        {"arch" => "b64"},
        nil
      ]
      described_class.add_system_call_rule(*args, test_file_name)
      pat = /^-a always,exit -F arch=b64 -S adjtimex\n/
      expect(test_file_contents).to match(pat)
    end
  end

  describe ".set_buffer_size" do
    it "replaces an existing value" do
      expect(test_file_contents).to match(/^-b \d+\n/)
      described_class.set_buffer_size(16_384, test_file_name)
      expect(test_file_contents).to match(/^-b 16384\n/)
    end
  end
end
