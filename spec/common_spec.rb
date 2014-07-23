require 'spec_helper'

describe LinuxAdmin::Common do
  subject { Class.new { include LinuxAdmin::Common }.new }

  context "#cmd" do
    it "looks up local command from id" do
      expect(subject.cmd(:dd)).to match(/bin\/dd/)
    end
  end

  it "#run" do
    expect(AwesomeSpawn).to receive(:run).with("echo", nil => "test")
    subject.run("echo", nil => "test")
  end

  it "#run!" do
    expect(AwesomeSpawn).to receive(:run!).with("echo", nil => "test")
    subject.run!("echo", nil => "test")
  end
end
