describe LinuxAdmin::Scap do
  subject { described_class.new("rhel7") }

  describe "#lockdown" do
    it "raises if given no rules" do
      allow(described_class).to receive(:openscap_available?).and_return(true)
      allow(described_class).to receive(:ssg_available?).and_return(true)

      expect { subject.lockdown("value1" => true) }.to raise_error(RuntimeError)
    end
  end

  describe "#profile_xml (private)" do
    it "creates a Profile tag" do
      profile_xml = subject.send(:profile_xml, "test-profile", [], {})
      expect(profile_xml).to match(%r{<Profile id="test-profile">.*</Profile>}m)
    end

    it "creates a title tag" do
      profile_xml = subject.send(:profile_xml, "test-profile", [], {})
      expect(profile_xml).to match(%r{<title>test-profile</title>}m)
    end

    it "creates a description tag" do
      profile_xml = subject.send(:profile_xml, "test-profile", [], {})
      expect(profile_xml).to match(%r{<description>test-profile</description>}m)
    end

    it "creates a select tag for each rule" do
      profile_xml = subject.send(:profile_xml, "test-profile", %w(rule1 rule2), {})
      expect(profile_xml).to match(%r{<select idref="rule1" selected="true"/>}m)
      expect(profile_xml).to match(%r{<select idref="rule2" selected="true"/>}m)
    end

    it "creates a refine-value tag for each value" do
      profile_xml = subject.send(:profile_xml, "test-profile", [], "key1" => "val1", "key2" => "val2")
      expect(profile_xml).to match(%r{<refine-value idref="key1" selector="val1"/>}m)
      expect(profile_xml).to match(%r{<refine-value idref="key2" selector="val2"/>}m)
    end
  end

  describe ".ds_file" do
    it "returns the platform ds file path" do
      file = described_class.ds_file("rhel7")
      expect(file.to_s).to eq("/usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml")
    end
  end
end
