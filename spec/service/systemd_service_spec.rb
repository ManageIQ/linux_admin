describe LinuxAdmin::SystemdService do
  before do
    @service = described_class.new 'foo'
  end

  describe "#running?" do
    it "checks service" do
      expect(@service).to receive(:run)
        .with(@service.cmd(:systemctl),
              :params => {nil => %w(status foo)}).and_return(double(:exit_status => 0))
      @service.running?
    end

    it "returns true when service is running" do
      expect(@service).to receive(:run).and_return(double(:exit_status => 0))
      expect(@service).to be_running
    end

    it "returns false when service is not running" do
      expect(@service).to receive(:run).and_return(double(:exit_status => 1))
      expect(@service).not_to be_running
    end
  end

  describe "#enable" do
    it "enables service" do
      expect(@service).to receive(:run!)
        .with(@service.cmd(:systemctl),
              :params => {nil => %w(enable foo)})
      @service.enable
    end

    it "returns self" do
      expect(@service).to receive(:run!) # stub out cmd invocation
      expect(@service.enable).to eq(@service)
    end
  end

  describe "#disable" do
    it "disables service" do
      expect(@service).to receive(:run!)
        .with(@service.cmd(:systemctl),
              :params => {nil => %w(disable foo)})
      @service.disable
    end

    it "returns self" do
      expect(@service).to receive(:run!)
      expect(@service.disable).to eq(@service)
    end
  end

  describe "#start" do
    it "starts service" do
      expect(@service).to receive(:run!)
        .with(@service.cmd(:systemctl),
              :params => {nil => %w(start foo)})
      @service.start
    end

    it "returns self" do
      expect(@service).to receive(:run!)
      expect(@service.start).to eq(@service)
    end
  end

  describe "#stop" do
    it "stops service" do
      expect(@service).to receive(:run!)
        .with(@service.cmd(:systemctl),
              :params => {nil => %w(stop foo)})
      @service.stop
    end

    it "returns self" do
      expect(@service).to receive(:run!)
      expect(@service.stop).to eq(@service)
    end
  end

  describe "#restart" do
    it "restarts service" do
      expect(@service).to receive(:run)
        .with(@service.cmd(:systemctl),
              :params => {nil => %w(restart foo)}).and_return(double(:exit_status => 0))
      @service.restart
    end

    it "manually stops then starts service when restart fails" do
      expect(@service).to receive(:run).and_return(double(:exit_status => 1))
      expect(@service).to receive(:stop)
      expect(@service).to receive(:start)
      @service.restart
    end

    it "returns self" do
      expect(@service).to receive(:run).and_return(double(:exit_status => 0))
      expect(@service.restart).to eq(@service)
    end
  end
end
