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
      stub_distro(:sh => '/bin/sh')
      subject.cmd(:sh).should == '/bin/sh'
    end

    it "complains when command not found" do
      expect { subject.cmd(:notfound) }.to raise_error
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
