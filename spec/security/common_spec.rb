describe LinuxAdmin::Security::Common do
  subject { Class.new { include LinuxAdmin::Security::Common }.new }

  def test_file_name
    File.join(data_file_path("security"), "common")
  end

  def test_file_contents
    File.read(test_file_name)
  end

  around(:each) do |example|
    text = test_file_contents
    example.run
    File.write(test_file_name, text)
  end

  describe ".replace_config_line" do
    it "replaces a matching value" do
      matches = /^NoOption no/.match(test_file_contents)
      expect(matches.size).to eq(1)

      matches = /^NoOption yes/.match(test_file_contents)
      expect(matches).to be_nil

      new_contents = subject.replace_config_line("NoOption yes\n", /^NoOpt.*\n/, test_file_contents)

      matches = /^NoOption yes/.match(new_contents)
      expect(matches.size).to eq(1)

      matches = /^NoOption no/.match(new_contents)
      expect(matches).to be_nil
    end

    it "adds a new line if no value matches" do
      matches = /^#*NotHereYet.*/.match(test_file_contents)
      expect(matches).to be_nil

      new_contents = subject.replace_config_line("NotHereYet yes", /^NoMatch/, test_file_contents)

      matches = /^NotHereYet yes/.match(new_contents)
      expect(matches.size).to eq(1)
    end
  end
end
