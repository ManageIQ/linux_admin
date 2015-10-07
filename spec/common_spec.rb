describe LinuxAdmin::Common do
  subject { Class.new { include LinuxAdmin::Common }.new }

  describe "#cmd" do
    it "looks up local command from id" do
      expect(subject.cmd(:dd)).to match(/bin\/dd/)
    end

    it "returns nil when it can't find the command" do
      expect(subject.cmd(:kasgbdlcvjhals)).to be_nil
    end
  end

  describe "#cmd?" do
    it "returns true when the command exists" do
      expect(subject.cmd?(:dd)).to be true
    end

    it "returns false when the command doesn't exist" do
      expect(subject.cmd?(:kasgbdlcvjhals)).to be false
    end
  end

  describe "#run" do
    it "runs a command with AwesomeSpawn.run" do
      expect(AwesomeSpawn).to receive(:run).with("echo", nil => "test")
      subject.run("echo", nil => "test")
    end
  end

  describe "#run!" do
    it "runs a command with AwesomeSpawn.run!" do
      expect(AwesomeSpawn).to receive(:run!).with("echo", nil => "test")
      subject.run!("echo", nil => "test")
    end
  end
end
