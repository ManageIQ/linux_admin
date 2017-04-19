describe LinuxAdmin::Common do
  describe "#cmd" do
    it "looks up local command from id" do
      expect(described_class.cmd(:dd)).to match(%r{bin/dd})
    end

    it "returns nil when it can't find the command" do
      expect(described_class.cmd(:kasgbdlcvjhals)).to be_nil
    end
  end

  describe "#cmd?" do
    it "returns true when the command exists" do
      expect(described_class.cmd?(:dd)).to be true
    end

    it "returns false when the command doesn't exist" do
      expect(described_class.cmd?(:kasgbdlcvjhals)).to be false
    end
  end

  [described_class, LinuxAdmin].each do |klass|
    describe "#{klass}.run" do
      it "runs a command with AwesomeSpawn.run" do
        expect(AwesomeSpawn).to receive(:run).with("echo", nil => "test")
        klass.run("echo", nil => "test")
      end
    end

    describe "#{klass}.run!" do
      it "runs a command with AwesomeSpawn.run!" do
        expect(AwesomeSpawn).to receive(:run!).with("echo", nil => "test")
        klass.run!("echo", nil => "test")
      end
    end
  end
end
