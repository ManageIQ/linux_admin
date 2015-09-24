describe LinuxAdmin::TimeDate do
  RUN_COMMAND = described_class.cmd("timedatectl")

  def timedatectl_result
    output = File.read(Pathname.new(data_file_path("time_date/timedatectl_output")))
    AwesomeSpawn::CommandResult.new("", output, "", 0)
  end

  describe ".timezone" do
    it "returns the correct timezone" do
      awesome_spawn_args = [
        RUN_COMMAND,
        :params => ["status"]
      ]
      expect(AwesomeSpawn).to receive(:run).with(*awesome_spawn_args).and_return(timedatectl_result)
      tz = described_class.timezone
      expect(tz).to eq("America/New_York (EDT, -0400)")
    end
  end

  describe ".set_system_time" do
    it "sets the time" do
      time = Time.new(2015, 1, 1, 1, 1, 1)
      awesome_spawn_args = [
        RUN_COMMAND,
        :params => ["set-time", "2015-01-01 01:01:01", :adjust_system_clock]
      ]
      expect(AwesomeSpawn).to receive(:run!).with(*awesome_spawn_args)
      described_class.set_system_time(time)
    end
  end

  describe ".set_system_timezone" do
    it "sets the timezone" do
      loc  = "Location"
      city = "City"
      awesome_spawn_args = [
        RUN_COMMAND,
        :params => ["set-timezone", "#{loc}/#{city}"]
      ]
      expect(AwesomeSpawn).to receive(:run!).with(*awesome_spawn_args)
      described_class.set_system_timezone(loc, city)
    end
  end
end
