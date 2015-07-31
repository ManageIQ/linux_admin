describe LinuxAdmin::Security::Useradd do
  def test_file_name
    File.join(data_file_path("security"), "useradd")
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
    it "sets INACTIVE to 35 days" do
      described_class.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^INACTIVE=35\n/)
    end
  end

  describe ".set_value" do
    it "replaces an existing value" do
      matches = /^ZERO=0/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^ZERO=1/.match(test_file_contents)
      expect(matches).to be_nil

      described_class.set_value("ZERO", 1, test_file_name)

      matches = /^ZERO=1/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^ZERO=0/.match(test_file_contents)
      expect(matches).to be_nil
    end

    it "replaces a # commented value" do
      matches = /^#COMMENT_ZERO=0/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^COMMENT_ZERO=1/.match(test_file_contents)
      expect(matches).to be_nil

      described_class.set_value("COMMENT_ZERO", 1, test_file_name)

      matches = /^COMMENT_ZERO=1/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^#COMMENT_ZERO=0/.match(test_file_contents)
      expect(matches).to be_nil
    end

    it "adds a new line if the key is not present at all" do
      matches = /^#*NOT_HERE.*/.match(test_file_contents)
      expect(matches).to be_nil

      described_class.set_value("NOT_HERE", 1, test_file_name)

      matches = /^NOT_HERE=1/.match(test_file_contents)
      expect(matches.size).to eq(1)
    end
  end
end
