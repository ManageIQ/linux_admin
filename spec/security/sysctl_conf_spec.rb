describe LinuxAdmin::Security::SysctlConf do
  def test_file_name
    File.join(data_file_path("security"), "sysctl.conf")
  end

  def test_file_contents
    File.read(test_file_name)
  end

  around(:each) do |example|
    text = test_file_contents
    example.run
    File.write(test_file_name, text)
  end

  describe "#apply_scap_settings" do
    it "unsets net.ipv4.conf.all.accept_redirects" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^net.ipv4.conf.all.accept_redirects = 0\n/)
    end

    it "unsets net.ipv4.conf.all.secure_redirects" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^net.ipv4.conf.all.secure_redirects = 0\n/)
    end

    it "sets net.ipv4.conf.all.log_martians" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^net.ipv4.conf.all.log_martians = 1\n/)
    end

    it "unsets net.ipv4.conf.default.secure_redirects" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^net.ipv4.conf.default.secure_redirects = 0\n/)
    end

    it "unsets net.ipv4.conf.default.accept_redirects" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^net.ipv4.conf.default.accept_redirects = 0\n/)
    end

    it "sets net.ipv4.icmp_echo_ignore_broadcasts" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^net.ipv4.icmp_echo_ignore_broadcasts = 1\n/)
    end

    it "sets net.ipv4.icmp_ignore_bogus_error_responses" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^net.ipv4.icmp_ignore_bogus_error_responses = 1\n/)
    end

    it "sets net.ipv4.conf.all.rp_filter" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^net.ipv4.conf.all.rp_filter = 1\n/)
    end

    it "unsets net.ipv6.conf.default.accept_redirects" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^net.ipv6.conf.default.accept_redirects = 0\n/)
    end

    it "unsets net.ipv4.conf.default.send_redirects" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^net.ipv4.conf.default.send_redirects = 0\n/)
    end

    it "unsets net.ipv4.conf.all.send_redirects" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^net.ipv4.conf.all.send_redirects = 0\n/)
    end
  end
end
