describe LinuxAdmin::Chrony do
  CHRONY_CONF = <<-EOF
# commented server baz.example.net
server foo.example.net
server bar.example.net iburst
driftfile /var/lib/chrony/drift
makestep 10 3
rtcsync
EOF

  subject do
    allow(File).to receive(:exist?).and_return(true)
    described_class.new
  end

  describe ".new" do
    it "raises when the given config file doesn't exist" do
      expect { described_class.new("nonsense/file") }.to raise_error(LinuxAdmin::MissingConfigurationFileError)
    end
  end

  describe "#clear_servers" do
    it "removes all the server lines from the conf file" do
      allow(File).to receive(:read).and_return(CHRONY_CONF.dup)
      expect(File).to receive(:write) do |_file, contents|
        expect(contents).to eq "# commented server baz.example.net\ndriftfile /var/lib/chrony/drift\nmakestep 10 3\nrtcsync\n"
      end
      subject.clear_servers
    end
  end

  describe "#add_servers" do
    it "adds server lines to the conf file" do
      allow(File).to receive(:read).and_return(CHRONY_CONF.dup)
      expect(File).to receive(:write) do |_file, contents|
        expect(contents).to eq(CHRONY_CONF + "server baz.example.net\nserver foo.bar.example.com\n")
      end
      subject.add_servers("baz.example.net", "foo.bar.example.com")
    end
  end
end
