describe LinuxAdmin::Service do
  context ".service_type" do
    it "on systemctl systems" do
      stub_to_service_type(:systemctl)
      expect(described_class.service_type).to eq(LinuxAdmin::Systemctl)
    end

    it "on sysv systems" do
      stub_to_service_type(:sysv_service)
      expect(described_class.service_type).to eq(LinuxAdmin::SysvService)
    end

    it "should memoize results" do
      expect(described_class).to receive(:service_type_uncached).once.and_return("anything_non_nil")
      described_class.service_type
      described_class.service_type
    end

    it "with reload should refresh results" do
      expect(described_class).to receive(:service_type_uncached).twice.and_return("anything_non_nil")
      described_class.service_type
      described_class.service_type(true)
    end
  end

  context ".new" do
    it "on systemctl systems" do
      stub_to_service_type(:systemctl)
      expect(described_class.new("xxx")).to be_kind_of(LinuxAdmin::Systemctl)
    end

    it "on sysv systems" do
      stub_to_service_type(:sysv_service)
      expect(described_class.new("xxx")).to be_kind_of(LinuxAdmin::SysvService)
    end
  end

  it "#id / #id=" do
    s = described_class.new("xxx")
    expect(s.id).to eq("xxx")

    s.id = "yyy"
    expect(s.id).to eq("yyy")
    expect(s.name).to eq("yyy")

    s.name = "zzz"
    expect(s.id).to eq("zzz")
    expect(s.name).to eq("zzz")
  end

  def stub_to_service_type(system)
    allow(LinuxAdmin::Service).to receive(:cmd?).with(:systemctl).and_return(system == :systemctl)
  end
end
