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
    File.open(test_file_name, "w") do |file|
      file.puts(text)
    end
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

  describe ".set_value" do
    it "replaces an existing value" do
      matches = /^\* +soft +core +100/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^\* +hard +core +0/.match(test_file_contents)
      expect(matches).to be_nil

      described_class.set_value("*", "hard", "core", 0, test_file_name)

      matches = /^\* +soft +core +100/.match(test_file_contents)
      expect(matches).to be_nil

      matches = /^\* +hard +core +0/.match(test_file_contents)
      expect(matches.size).to eq(1)
    end

    it "adds a new line if the item type is not present" do
      matches = /maxlogins/.match(test_file_contents)
      expect(matches).to be_nil

      described_class.set_value("*", "hard", "maxlogins", 10, test_file_name)

      matches = /^\* +hard +maxlogins +10/.match(test_file_contents)
      expect(matches.size).to eq(1)
    end
  end
end
