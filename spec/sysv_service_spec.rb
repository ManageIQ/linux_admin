describe LinuxAdmin::SysvService do
  before(:each) do
    @service = described_class.new 'foo'
  end

  describe "#running?" do
    it "checks service" do
      expect(@service).to receive(:run).
         with(@service.cmd(:service),
              :params => { nil => ['foo', 'status']}).and_return(double(:exit_status => 0))
      @service.running?
    end

    context "service is running" do
      it "returns true" do
        @service = described_class.new :id => :foo
        expect(@service).to receive(:run).and_return(double(:exit_status => 0))
        expect(@service).to be_running
     end
    end

    context "service is not running" do
      it "returns false" do
        @service = described_class.new :id => :foo
        expect(@service).to receive(:run).and_return(double(:exit_status => 1))
        expect(@service).not_to be_running
      end
    end
  end

  describe "#enable" do
    it "enables service" do
      expect(@service).to receive(:run!).
         with(@service.cmd(:chkconfig),
              :params => { nil => [ 'foo', 'on']})
      @service.enable
    end

    it "returns self" do
      expect(@service).to receive(:run!) # stub out cmd invocation
      expect(@service.enable).to eq(@service)
    end
  end

  describe "#disable" do
    it "disable service" do
      expect(@service).to receive(:run!).
         with(@service.cmd(:chkconfig),
              :params => { nil => [ 'foo', 'off']})
      @service.disable
    end

    it "returns self" do
      expect(@service).to receive(:run!)
      expect(@service.disable).to eq(@service)
    end
  end

  describe "#start" do
    it "starts service" do
      expect(@service).to receive(:run!).
         with(@service.cmd(:service),
              :params => { nil => [ 'foo', 'start']})
      @service.start
    end

    it "returns self" do
      expect(@service).to receive(:run!)
      expect(@service.start).to eq(@service)
    end
  end

  describe "#stop" do
    it "stops service" do
      expect(@service).to receive(:run!).
         with(@service.cmd(:service),
              :params => { nil => [ 'foo', 'stop']})
      @service.stop
    end

    it "returns self" do
      expect(@service).to receive(:run!)
      expect(@service.stop).to eq(@service)
    end
  end

  describe "#restart" do
    it "stops service" do
      expect(@service).to receive(:run).
         with(@service.cmd(:service),
              :params => { nil => [ 'foo', 'restart']}).and_return(double(:exit_status => 0))
      @service.restart
    end

    context "service restart fails" do
      it "manually stops/starts service" do
        expect(@service).to receive(:run).and_return(double(:exit_status => 1))
        expect(@service).to receive(:stop)
        expect(@service).to receive(:start)
        @service.restart
      end
    end

    it "returns self" do
      expect(@service).to receive(:run).and_return(double(:exit_status => 0))
      expect(@service.restart).to eq(@service)
    end
  end

end
