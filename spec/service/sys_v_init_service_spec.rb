describe LinuxAdmin::SysVInitService do
  before do
    @service = described_class.new 'foo'
  end

  describe "#running?" do
    it "checks service" do
      expect(LinuxAdmin::Common).to receive(:run)
        .with(LinuxAdmin::Common.cmd(:service),
              :params => {nil => %w(foo status)}).and_return(double(:exit_status => 0))
      @service.running?
    end

    context "service is running" do
      it "returns true" do
        @service = described_class.new :id => :foo
        expect(LinuxAdmin::Common).to receive(:run).and_return(double(:exit_status => 0))
        expect(@service).to be_running
      end
    end

    context "service is not running" do
      it "returns false" do
        @service = described_class.new :id => :foo
        expect(LinuxAdmin::Common).to receive(:run).and_return(double(:exit_status => 1))
        expect(@service).not_to be_running
      end
    end
  end

  describe "#enable" do
    it "enables service" do
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:chkconfig),
              :params => {nil => %w(foo on)})
      @service.enable
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run!) # stub out cmd invocation
      expect(@service.enable).to eq(@service)
    end
  end

  describe "#disable" do
    it "disable service" do
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:chkconfig),
              :params => {nil => %w(foo off)})
      @service.disable
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run!)
      expect(@service.disable).to eq(@service)
    end
  end

  describe "#start" do
    it "starts service" do
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:service),
              :params => {nil => %w(foo start)})
      @service.start
    end

    it "also enables the service if passed true" do
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:service),
              :params => {nil => %w(foo start)})
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:chkconfig),
              :params => {nil => %w(foo on)})
      @service.start(true)
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run!)
      expect(@service.start).to eq(@service)
    end
  end

  describe "#stop" do
    it "stops service" do
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:service),
              :params => {nil => %w(foo stop)})
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
        .with(LinuxAdmin::Common.cmd(:service),
              :params => {nil => %w(foo restart)}).and_return(double(:exit_status => 0))
      @service.restart
    end

    context "service restart fails" do
      it "manually stops/starts service" do
        expect(LinuxAdmin::Common).to receive(:run).and_return(double(:exit_status => 1))
        expect(@service).to receive(:stop)
        expect(@service).to receive(:start)
        @service.restart
      end
    end

    it "returns self" do
      expect(LinuxAdmin::Common).to receive(:run).and_return(double(:exit_status => 0))
      expect(@service.restart).to eq(@service)
    end
  end

  describe "#reload" do
    it "reloads service" do
      expect(LinuxAdmin::Common).to receive(:run!)
        .with(LinuxAdmin::Common.cmd(:service), :params => %w(foo reload))
      expect(@service.reload).to eq(@service)
    end
  end

  describe "#status" do
    it "returns the service status" do
      status = "service status here"
      expect(LinuxAdmin::Common).to receive(:run)
        .with(LinuxAdmin::Common.cmd(:service),
              :params => %w(foo status)).and_return(double(:output => status))
      expect(@service.status).to eq(status)
    end
  end
end
