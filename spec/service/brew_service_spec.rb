describe LinuxAdmin::BrewService do
  before do
    @service = described_class.new 'foo'
    allow(LinuxAdmin::Common).to receive(:cmd).with(:brew).and_return("brew")
  end

  describe "#running?" do
    it "checks service" do
      expect(LinuxAdmin::Common).to receive(:run)
        .with("brew",
              :params => %w(services list)).and_return(double(:output => "foo params running\nother param running\n"))
      @service.running?
    end

    it "returns true when service is running" do
      expect(LinuxAdmin::Common).to receive(:run)
        .and_return(double(:output => "foo  param file\nother params running\n"))
      expect(@service).to be_running
    end

    it "returns false when service is not running" do
      expect(LinuxAdmin::Common).to receive(:run).and_return(double(:output => "other\n"))
      expect(@service).not_to be_running
    end

    it "returns false when service is not running (even though name is close" do
      expect(LinuxAdmin::Common).to receive(:run)
        .and_return(double(:output => "foo2 param running\nother param running\n"))
      expect(@service).not_to be_running
    end
  end

  describe "#enable" do
    it "enables service" do
      expect(LinuxAdmin::Common).to receive(:run!).with("brew", :params => %w(services start foo))
      @service.enable
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run!) # stub out cmd invocation
      expect(@service.enable).to eq(@service)
    end
  end

  describe "#disable" do
    it "stops the service" do
      expect(LinuxAdmin::Common).to receive(:run!).with("brew", :params => %w(services stop foo))
      @service.disable
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run!)
      expect(@service.disable).to eq(@service)
    end
  end

  describe "#start" do
    it "starts service" do
      expect(LinuxAdmin::Common).to receive(:run!).with("brew", :params => %w(services start foo))
      @service.start
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run!)
      expect(@service.start).to eq(@service)
    end
  end

  describe "#stop" do
    it "stops service" do
      expect(LinuxAdmin::Common).to receive(:run!).with("brew", :params => %w(services stop foo))
      @service.stop
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run!)
      expect(@service.stop).to eq(@service)
    end
  end

  describe "#restart" do
    it "restarts service" do
      expect(LinuxAdmin::Common).to receive(:run)
        .with("brew", :params => %w(services restart foo)).and_return(double(:success? => true))
      @service.restart
    end

    it "manually stops then starts service when restart fails" do
      expect(LinuxAdmin::Common).to receive(:run).and_return(double(:success? => false))
      expect(@service).to receive(:stop)
      expect(@service).to receive(:start)
      @service.restart
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run).and_return(double(:success? => true))
      expect(@service.restart).to eq(@service)
    end
  end
end
