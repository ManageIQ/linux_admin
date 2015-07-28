
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
    File.open(test_file_name, "w") do |file|
      file.puts(text)
    end
  end

  describe ".set_value" do
    it "replaces an existing value" do
      matches = /^data\.security\.one = 1/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^data\.security\.one = 0/.match(test_file_contents)
      expect(matches).to be_nil

      described_class.set_value("data.security.one", 0, test_file_name)

      matches = /^data\.security\.one = 0/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^data\.security\.one = 1/.match(test_file_contents)
      expect(matches).to be_nil
    end

    it "replaces a # commented value" do
      matches = /^#data\.security\.commented\.zero = 0/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^data\.security\.commented\.zero = 1/.match(test_file_contents)
      expect(matches).to be_nil

      described_class.set_value("data.security.commented.zero", 1, test_file_name)

      matches = /^#data\.security\.commented\.zero = 0/.match(test_file_contents)
      expect(matches).to be_nil

      matches = /^data\.security\.commented\.zero = 1/.match(test_file_contents)
      expect(matches.size).to eq(1)
    end

    it "replaces a ; commented value" do
      matches = /^;data\.security\.commented\.semi.one = 1/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^data\.security\.commented\.semi\.one = 0/.match(test_file_contents)
      expect(matches).to be_nil

      described_class.set_value("data.security.commented.semi.one", 0, test_file_name)

      matches = /^;data\.security\.commented\.semi\.one = 1/.match(test_file_contents)
      expect(matches).to be_nil

      matches = /^data\.security\.commented\.semi\.one = 0/.match(test_file_contents)
      expect(matches.size).to eq(1)
    end

    it "adds a new line if the key is not present at all" do
      matches = /^[#;]*not\.here\.yet.*/.match(test_file_contents)
      expect(matches).to be_nil

      described_class.set_value("not.here.yet", 1, test_file_name)

      matches = /^not\.here\.yet = 1/.match(test_file_contents)
      expect(matches.size).to eq(1)
    end
  end
end
