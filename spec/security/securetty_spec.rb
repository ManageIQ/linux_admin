describe LinuxAdmin::Security::Securetty do
  def test_file_name
    File.join(data_file_path("security"), "securetty")
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
    it "removes all vc entries" do
      expect(test_file_contents).to match(%r{^vc/\d+})

      described_class.new.apply_scap_settings(test_file_name)

      expect(test_file_contents).not_to match(%r{^vc/\d+})
    end

    it "does not remove other entries" do
      expect(test_file_contents).to match(/^tty\d+/)
      expect(test_file_contents).to match(/^hvc\d+/)

      described_class.new.apply_scap_settings(test_file_name)

      expect(test_file_contents).to match(/^tty\d+/)
      expect(test_file_contents).to match(/^hvc\d+/)
    end
  end
end
