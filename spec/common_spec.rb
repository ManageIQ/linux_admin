require 'spec_helper'

describe LinuxAdmin::Common do
  before do
    class TestClass
      extend LinuxAdmin::Common
    end
  end

  after do
    Object.send(:remove_const, :TestClass)
  end

  subject { TestClass }

  context "#cmd" do
    it "looks up local command from id" do
      expect(subject.cmd(:dd)).to match(/bin\/dd/)
    end
  end

  it "#run" do
    AwesomeSpawn.should_receive(:run).with("echo", nil => "test")
    subject.run("echo", nil => "test")
  end

  it "#run!" do
    AwesomeSpawn.should_receive(:run!).with("echo", nil => "test")
    subject.run!("echo", nil => "test")
  end
end
