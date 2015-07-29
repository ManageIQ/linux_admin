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
    File.open(test_file_name, "w") do |file|
      file.puts(text)
    end
  end

  describe ".remove_vcs" do
    it "removes all vc entries" do
      expect(test_file_contents).to match(%r{^vc/\d+})

      described_class.remove_vcs(test_file_name)

      expect(test_file_contents).not_to match(%r{^vc/\d+})
    end

    it "does not remove other entries" do
      expect(test_file_contents).to match(/^tty\d+/)
      expect(test_file_contents).to match(/^hvc\d+/)

      described_class.remove_vcs(test_file_name)

      expect(test_file_contents).to match(/^tty\d+/)
      expect(test_file_contents).to match(/^hvc\d+/)
    end
  end
end