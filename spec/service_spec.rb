require 'spec_helper'

describe LinuxAdmin::Service do
  before(:each) do
    @service = LinuxAdmin::Service.new 'foo'
  end

  describe "#running?" do
    it "checks service" do
      @service.should_receive(:run).
         with(@service.cmd(:service),
              :params => { nil => ['foo', 'status']},
              :return_exitstatus => true)
      @service.running?
    end

    context "service is running" do
      it "returns true" do
        @service = LinuxAdmin::Service.new :id => :foo
        @service.should_receive(:run).and_return(0)
        @service.should be_running
     end
    end

    context "service is not running" do
      it "returns false" do
        @service = LinuxAdmin::Service.new :id => :foo
        @service.should_receive(:run).and_return(1)
        @service.should_not be_running
      end
    end
  end

  describe "#enable" do
    it "enables service" do
      @service.should_receive(:run).
         with(@service.cmd(:systemctl),
              :params => { nil => [ 'enable', 'foo.service']})
      @service.enable
    end
  end

  describe "#disable" do
    it "disable service" do
      @service.should_receive(:run).
         with(@service.cmd(:systemctl),
              :params => { nil => [ 'disable', 'foo.service']})
      @service.disable
    end
  end

  describe "#start" do
    it "starts service" do
      @service.should_receive(:run).
         with(@service.cmd(:service),
              :params => { nil => [ 'foo', 'start']})
      @service.start
    end
  end

  describe "#stop" do
    it "stops service" do
      @service.should_receive(:run).
         with(@service.cmd(:service),
              :params => { nil => [ 'foo', 'stop']})
      @service.stop
    end
  end
end
