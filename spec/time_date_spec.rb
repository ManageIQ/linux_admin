describe LinuxAdmin::TimeDate do
  RUN_COMMAND = LinuxAdmin::Common.cmd("timedatectl")

  def timedatectl_result
    output = File.read(Pathname.new(data_file_path("time_date/timedatectl_output")))
    AwesomeSpawn::CommandResult.new("", output, "", 0)
  end

  describe ".system_timezone_detailed" do
    it "returns the correct timezone" do
      awesome_spawn_args = [
        RUN_COMMAND,
        :params => ["status"]
      ]
      expect(AwesomeSpawn).to receive(:run).with(*awesome_spawn_args).and_return(timedatectl_result)
      tz = described_class.system_timezone_detailed
      expect(tz).to eq("America/New_York (EDT, -0400)")
    end
  end

  describe ".system_timezone" do
    it "returns the correct timezone" do
      awesome_spawn_args = [
        RUN_COMMAND,
        :params => ["status"]
      ]
      expect(AwesomeSpawn).to receive(:run).with(*awesome_spawn_args).and_return(timedatectl_result)
      tz = described_class.system_timezone
      expect(tz).to eq("America/New_York")
    end
  end

  describe ".system_time=" do
    it "sets the time" do
      time = Time.new(2015, 1, 1, 1, 1, 1)
      awesome_spawn_args = [
        RUN_COMMAND,
        :params => ["set-time", "2015-01-01 01:01:01", :adjust_system_clock]
      ]
      expect(AwesomeSpawn).to receive(:run!).with(*awesome_spawn_args)
      described_class.system_time = time
    end

    it "raises when the command fails" do
      time = Time.new(2015, 1, 1, 1, 1, 1)
      err = AwesomeSpawn::CommandResultError.new("message", nil)
      allow(AwesomeSpawn).to receive(:run!).and_raise(err)
      expect do
        described_class.send(:system_time=, time)
      end.to raise_error(described_class::TimeCommandError, "message")
    end
  end

  describe ".system_timezone=" do
    it "sets the timezone" do
      zone = "Location/City"
      awesome_spawn_args = [
        RUN_COMMAND,
        :params => ["set-timezone", zone]
      ]
      expect(AwesomeSpawn).to receive(:run!).with(*awesome_spawn_args)
      described_class.system_timezone = zone
    end

    it "raises when the command fails" do
      zone = "Location/City"
      err = AwesomeSpawn::CommandResultError.new("message", nil)
      allow(AwesomeSpawn).to receive(:run!).and_raise(err)
      expect do
        described_class.send(:system_timezone=, zone)
      end.to raise_error(described_class::TimeCommandError, "message")
    end
  end
end
