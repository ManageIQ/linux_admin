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
    File.open(test_file_name, "w") do |file|
      file.puts(text)
    end
  end

  describe ".set_value" do
    it "replaces an existing value" do
      matches = /^NoOption no/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^NoOption yes/.match(test_file_contents)
      expect(matches).to be_nil

      described_class.set_value("NoOption", "yes", test_file_name)

      matches = /^NoOption yes/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^NoOption no/.match(test_file_contents)
      expect(matches).to be_nil
    end

    it "replaces a commented value" do
      matches = /^#CommentedNoOption no/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^CommentedNoOption yes/.match(test_file_contents)
      expect(matches).to be_nil

      described_class.set_value("CommentedNoOption", "yes", test_file_name)

      matches = /^#CommentedNoOption no/.match(test_file_contents)
      expect(matches).to be_nil

      matches = /^CommentedNoOption yes/.match(test_file_contents)
      expect(matches.size).to eq(1)
    end

    it "adds a new line if the key is not present at all" do
      matches = /^#*NotHereYet.*/.match(test_file_contents)
      expect(matches).to be_nil

      described_class.set_value("NotHereYet", "yes", test_file_name)

      matches = /^NotHereYet yes/.match(test_file_contents)
      expect(matches.size).to eq(1)
    end
  end
end
