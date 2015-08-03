describe LinuxAdmin::Security::SshdConfig do
  def test_file_name
    File.join(data_file_path("security"), "sshd_config")
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
    it "sets PermitUserEnvironment to no" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^PermitUserEnvironment *no\n/)
    end

    it "sets PermitEmptyPasswords to no" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^PermitEmptyPasswords *no\n/)
    end

    it "sets Ciphers to strong ciphers" do
      described_class.new.apply_scap_settings(test_file_name)
      strong_ciphers = ["aes128-ctr", "aes192-ctr", "aes256-ctr", "aes128-cbc",
                        "3des-cbc", "aes192-cbc", "aes256-cbc"]
      /Ciphers *([\w,]*)\n/.match(test_file_contents) do |m|
        actual_ciphers = m[1].split(",")
        actual_ciphers.each do |c|
          expect(strong_ciphers).to include(c)
        end
      end
    end

    it "sets ClientAliveInterval to 900" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^ClientAliveInterval *900\n/)
    end

    it "sets ClientAliveCountMax to 0" do
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^ClientAliveCountMax *0\n/)
    end
  end
end
