describe LinuxAdmin::Process::Memory do
  before do
    @smaps = File.read(Pathname.new(data_file_path("process/memory/smaps")))
  end

  subject do
    described_class.new(nil, @smaps)
  end

  it "#pss" do
    expect(subject.pss).to eq 107
  end

  it "#rss" do
    expect(subject.rss).to eq 368
  end

  it "#uss" do
    expect(subject.uss).to eq 96
  end

  it "#shared" do
    expect(subject.shared).to eq 272
  end

  it "#swap" do
    expect(subject.swap).to eq 192
  end

  it "#size" do
    expect(subject.size).to eq 136752
  end
end
