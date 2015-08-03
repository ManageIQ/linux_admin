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
      described_class.new.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(/^INACTIVE=35\n/)
    end
  end
end
