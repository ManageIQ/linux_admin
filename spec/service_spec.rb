require 'spec_helper'

describe LinuxAdmin::Service do
  before(:each) do
    # stub distro.local to return test distro for command lookup
    LinuxAdmin::Distro.stub(:local).
                       and_return(LinuxAdmin::Distros::Test.new)

    @service = LinuxAdmin::Service.new 'foo'
  end

  describe "#running?" do
    it "checks service" do
      @service.should_receive(:run).
         with(@service.cmd(:service),
              :params => { nil => ['foo', 'status']}).and_return(double(:exit_status => 0))
      @service.running?
    end

    context "service is running" do
      it "returns true" do
        @service = LinuxAdmin::Service.new :id => :foo
        @service.should_receive(:run).and_return(double(:exit_status => 0))
        @service.should be_running
     end
    end

    context "service is not running" do
      it "returns false" do
        @service = LinuxAdmin::Service.new :id => :foo
        @service.should_receive(:run).and_return(double(:exit_status => 1))
        @service.should_not be_running
      end
    end
  end

  describe "#enable" do
    it "enables service" do
      @service.should_receive(:run!).
         with(@service.cmd(:chkconfig),
              :params => { nil => [ 'foo', 'on']})
      @service.enable
    end

    it "returns self" do
      @service.should_receive(:run!) # stub out cmd invocation
      @service.enable.should == @service
    end
  end

  describe "#disable" do
    it "disable service" do
      @service.should_receive(:run!).
         with(@service.cmd(:chkconfig),
              :params => { nil => [ 'foo', 'off']})
      @service.disable
    end

    it "returns self" do
      @service.should_receive(:run!)
      @service.disable.should == @service
    end
  end

  describe "#start" do
    it "starts service" do
      @service.should_receive(:run!).
         with(@service.cmd(:service),
              :params => { nil => [ 'foo', 'start']})
      @service.start
    end

    it "returns self" do
      @service.should_receive(:run!)
      @service.start.should == @service
    end
  end

  describe "#stop" do
    it "stops service" do
      @service.should_receive(:run!).
         with(@service.cmd(:service),
              :params => { nil => [ 'foo', 'stop']})
      @service.stop
    end

    it "returns self" do
      @service.should_receive(:run!)
      @service.stop.should == @service
    end
  end

  describe "#restart" do
    it "stops service" do
      @service.should_receive(:run).
         with(@service.cmd(:service),
              :params => { nil => [ 'foo', 'restart']}).and_return(double(:exit_status => 0))
      @service.restart
    end

    context "service restart fails" do
      it "manually stops/starts service" do
        @service.should_receive(:run).and_return(double(:exit_status => 1))
        @service.should_receive(:stop)
        @service.should_receive(:start)
        @service.restart
      end
    end

    it "returns self" do
      @service.should_receive(:run).and_return(double(:exit_status => 0))
      @service.restart.should == @service
    end
  end

end
