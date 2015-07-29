describe LinuxAdmin::Security::LoginDefs do
  def test_file_name
    File.join(data_file_path("security"), "login.defs")
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
    it "sets PASS_MIN_DAYS to 1" do
      described_class.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^PASS_MIN_DAYS +1\n/)
    end
  end
end
