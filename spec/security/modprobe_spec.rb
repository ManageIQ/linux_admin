describe LinuxAdmin::Security::Modprobe do
  def test_file_name
    File.join(data_file_path("security"), "modprobe_lockdown")
  end

  def new_file_name
    File.join(data_file_path("security"), "modprobe_new")
  end

  def test_file_contents
    File.read(test_file_name)
  end

  def new_file_contents
    File.read(new_file_name)
  end

  around(:each) do |example|
    text = test_file_contents
    example.run
    File.write(test_file_name, text)
  end

  describe ".apply_scap_settings" do
    it "disables the dccp protocol" do
      described_class.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(%r{^install dccp /bin/true\n})
    end

    it "disables the sctp protocol" do
      described_class.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(%r{^install sctp /bin/true\n})
    end

    it "disables the rds protocol" do
      described_class.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(%r{^install rds /bin/true\n})
    end

    it "disables the tipc protocol" do
      described_class.apply_scap_settings(test_file_name)
      expect(test_file_contents).to match(%r{^install tipc /bin/true\n})
    end
  end

  describe ".disable_module" do
    it "adds a module to the file" do
      described_class.disable_module("test_module", test_file_name)
      expect(test_file_contents).to match(%r{^install test_module /bin/true\n})
    end

    context "creates a file" do
      after do
        File.exist?(new_file_name) && File.delete(new_file_name)
      end
      it "if the given one doesn't exist" do
        expect(File.exist?(new_file_name)).to be false
        described_class.disable_module("test_module", new_file_name)
        expect(File.exist?(new_file_name)).to be true
        expect(new_file_contents).to match(%r{^install test_module /bin/true\n})
      end
    end
  end

  describe ".enable_module" do
    it "removes a module from the file" do
      pat = %r{^install good_module /bin/true\n}
      expect(test_file_contents).to match(pat)
      described_class.enable_module("good_module", test_file_name)
      expect(test_file_contents).not_to match(pat)
    end

    it "succeeds if the given file doesn't exist" do
      expect(File.exist?(new_file_name)).to be false
      described_class.enable_module("test_module", new_file_name)
      expect(File.exist?(new_file_name)).to be false
    end
  end
end
