describe LinuxAdmin::SysVInitService do
  before do
    @service = described_class.new 'foo'
    allow(LinuxAdmin::Common).to receive(:cmd).with(:service).and_return("service")
    allow(LinuxAdmin::Common).to receive(:cmd).with(:chkconfig).and_return("chkconfig")
  end

  describe "#running?" do
    it "checks service" do
      expect(LinuxAdmin::Common).to receive(:run)
        .with("service", :params => %w(foo status)).and_return(double(:success? => true))
      @service.running?
    end

    context "service is running" do
      it "returns true" do
        @service = described_class.new :id => :foo
        expect(LinuxAdmin::Common).to receive(:run).and_return(double(:success? => true))
        expect(@service).to be_running
      end
    end

    context "service is not running" do
      it "returns false" do
        @service = described_class.new :id => :foo
        expect(LinuxAdmin::Common).to receive(:run).and_return(double(:success? => false))
        expect(@service).not_to be_running
      end
    end
  end

  describe "#enable" do
    it "enables service" do
      expect(LinuxAdmin::Common).to receive(:run!).with("chkconfig", :params => %w(foo on))
      @service.enable
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run!) # stub out cmd invocation
      expect(@service.enable).to eq(@service)
    end
  end

  describe "#disable" do
    it "disable service" do
      expect(LinuxAdmin::Common).to receive(:run!).with("chkconfig", :params => %w(foo off))
      @service.disable
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run!)
      expect(@service.disable).to eq(@service)
    end
  end

  describe "#start" do
    it "starts service" do
      expect(LinuxAdmin::Common).to receive(:run!).with("service", :params => %w(foo start))
      @service.start
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run!)
      expect(@service.start).to eq(@service)
    end
  end

  describe "#stop" do
    it "stops service" do
      expect(LinuxAdmin::Common).to receive(:run!).with("service", :params => %w(foo stop))
      @service.stop
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run!)
      expect(@service.stop).to eq(@service)
    end
  end

  describe "#restart" do
    it "stops service" do
      expect(LinuxAdmin::Common).to receive(:run)
        .with("service", :params => %w(foo restart)).and_return(double(:success? => true))
      @service.restart
    end

    context "service restart fails" do
      it "manually stops/starts service" do
        expect(LinuxAdmin::Common).to receive(:run).and_return(double(:success? => false))
        expect(@service).to receive(:stop)
        expect(@service).to receive(:start)
        @service.restart
      end
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run).and_return(double(:success? => true))
      expect(@service.restart).to eq(@service)
    end
  end
end
