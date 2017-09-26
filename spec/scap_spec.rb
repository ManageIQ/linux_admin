describe LinuxAdmin::Scap do
  subject(:rhel7) { described_class.new("rhel7") }
  subject(:rhel6) { described_class.new("rhel6") }

  describe "#lockdown" do
    it "raises if given no rules" do
      stub_const("LinuxAdmin::Scap::SSG_XML_PATH", Pathname.new(data_file_path("scap")))
      scap = described_class.new
      allow(described_class).to receive(:openscap_available?).and_return(true)
      allow(described_class).to receive(:ssg_available?).and_return(true)
      allow(scap).to receive(:lockdown_profile)
      expect { scap.lockdown("value1" => true) }.to raise_error(RuntimeError)
    end
  end

  describe "#xccdf_file (private)" do
    it "uses the platform from the attribute" do
      stub_const("LinuxAdmin::Scap::SSG_XML_PATH", Pathname.new(data_file_path("scap")))
      expect(rhel7.send(:xccdf_file)).to eq("#{data_file_path("scap")}/ssg-rhel7-xccdf.xml")
      expect(rhel6.send(:xccdf_file)).to eq("#{data_file_path("scap")}/ssg-rhel6-xccdf.xml")
    end
  end

  describe "#oval_file (private)" do
    it "uses the platform from the attribute" do
      stub_const("LinuxAdmin::Scap::SSG_XML_PATH", Pathname.new(data_file_path("scap")))
      expect(rhel7.send(:oval_file)).to eq("#{data_file_path("scap")}/ssg-rhel7-oval.xml")
      expect(rhel6.send(:oval_file)).to eq("#{data_file_path("scap")}/ssg-rhel6-oval.xml")
    end
  end

  describe "#profile_xml (private)" do
    it "creates a Profile tag" do
      profile_xml = described_class.new.send(:profile_xml, "test-profile", [], {})
      expect(profile_xml).to match(%r{<Profile id="test-profile">.*</Profile>}m)
    end

    it "creates a title tag" do
      profile_xml = described_class.new.send(:profile_xml, "test-profile", [], {})
      expect(profile_xml).to match(%r{<title>test-profile</title>}m)
    end

    it "creates a description tag" do
      profile_xml = described_class.new.send(:profile_xml, "test-profile", [], {})
      expect(profile_xml).to match(%r{<description>test-profile</description>}m)
    end

    it "creates a select tag for each rule" do
      profile_xml = described_class.new.send(:profile_xml, "test-profile", %w(rule1 rule2), {})
      expect(profile_xml).to match(%r{<select idref="rule1" selected="true"/>}m)
      expect(profile_xml).to match(%r{<select idref="rule2" selected="true"/>}m)
    end

    it "creates a refine-value tag for each value" do
      profile_xml = described_class.new.send(:profile_xml, "test-profile", [], "key1" => "val1", "key2" => "val2")
      expect(profile_xml).to match(%r{<refine-value idref="key1" selector="val1"/>}m)
      expect(profile_xml).to match(%r{<refine-value idref="key2" selector="val2"/>}m)
    end
  end

  describe ".local_ssg_file (private)" do
    it "returns nil if the file doesn't exist" do
      stub_const("LinuxAdmin::Scap::SSG_XML_PATH", Pathname.new("/doesnt/exist/"))
      file = described_class.send(:local_ssg_file, "type", nil)
      expect(file).to be_nil
    end

    it "returns a file if there are multiple matches" do
      stub_const("LinuxAdmin::Scap::SSG_XML_PATH", Pathname.new(data_file_path("scap")))
      file = described_class.send(:local_ssg_file, "xccdf", nil)
      expect(file).to match(%r{.*/ssg-\w+-xccdf\.xml})
    end

    it "returns a matching file" do
      stub_const("LinuxAdmin::Scap::SSG_XML_PATH", Pathname.new(data_file_path("scap")))
      file = described_class.send(:local_ssg_file, "oval", nil)
      expect(file).to eq("#{data_file_path("scap")}/ssg-rhel7-oval.xml")
    end
  end
end
