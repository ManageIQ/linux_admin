describe LinuxAdmin::Security::LimitsConf do
  def test_file_name
    File.join(data_file_path("security"), "limits.conf")
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
    it "prevents process core dumps" do
      described_class.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^\* +hard +core +0\n/)
    end

    it "sets max logins to 10" do
      described_class.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^\* +hard +maxlogins +10\n/)
    end
  end
end
