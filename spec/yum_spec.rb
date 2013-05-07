require 'spec_helper'

describe LinuxAdmin::Yum do
  it ".create_repo" do
    LinuxAdmin::Common.stub(:run => true)
    expect(described_class.create_repo("some_path")).to be_true
  end

  context ".updates_available?" do
    it "updates are available" do
      LinuxAdmin::Common.stub(:run => 100)
      expect(described_class.updates_available?).to be_true
    end

    it "updates not available" do
      LinuxAdmin::Common.stub(:run => 0)
      expect(described_class.updates_available?).to be_false
    end

    it "other exit code" do
      LinuxAdmin::Common.stub(:run => 255)
      expect { described_class.updates_available? }.to raise_error
    end

    it "other error" do
      LinuxAdmin::Common.stub(:run).and_raise(RuntimeError)
      expect { described_class.updates_available? }.to raise_error
    end
  end

  it ".update" do
    LinuxAdmin::Common.should_receive(:run).once
    described_class.update
  end
end