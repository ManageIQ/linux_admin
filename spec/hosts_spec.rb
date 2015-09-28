describe LinuxAdmin::Hosts do
  etc_hosts = "\n #Some Comment\n127.0.0.1\tlocalhost localhost.localdomain # with a comment\n127.0.1.1  my.domain.local"
  before do
    allow(File).to receive(:read).and_return(etc_hosts)
    @instance = LinuxAdmin::Hosts.new
  end

  describe "#reload" do
    it "sets raw_lines" do
      expected_array = ["", " #Some Comment", "127.0.0.1\tlocalhost localhost.localdomain # with a comment", "127.0.1.1  my.domain.local"]
      expect(@instance.raw_lines).to eq(expected_array)
    end

    it "sets parsed_file" do
      expected_hash = [{:blank=>true}, {:comment=>"Some Comment"}, {:address=>"127.0.0.1", :hosts=>["localhost", "localhost.localdomain"], :comment=>"with a comment"}, {:address=>"127.0.1.1", :hosts=>["my.domain.local"]}]
      expect(@instance.parsed_file).to eq(expected_hash)
    end
  end

  describe "#update_entry" do
    it "removes an existing entry and creates a new one" do
      expected_hash = [{:blank=>true}, {:comment=>"Some Comment"}, {:address=>"127.0.0.1", :hosts=>["localhost", "localhost.localdomain"], :comment=>"with a comment"}, {:address=>"127.0.1.1", :hosts=>[]}, {:address=>"1.2.3.4", :hosts=>["my.domain.local"], :comment=>nil}]
      @instance.update_entry("1.2.3.4", "my.domain.local")
      expect(@instance.parsed_file).to eq(expected_hash)
    end

    it "updates an existing entry" do
      expected_hash = [{:blank=>true}, {:comment=>"Some Comment"}, {:address=>"127.0.0.1", :hosts=>["localhost", "localhost.localdomain", "new.domain.local"], :comment=>"with a comment"}, {:address=>"127.0.1.1", :hosts=>["my.domain.local"]}]
      @instance.update_entry("127.0.0.1", "new.domain.local")
      expect(@instance.parsed_file).to eq(expected_hash)
    end
  end

  describe "#save" do
    before do
      allow(File).to receive(:write)
    end

    it "properly generates file with new content" do
      expected_array = ["", "#Some Comment", "127.0.0.1        localhost localhost.localdomain #with a comment", "127.0.1.1        my.domain.local", "1.2.3.4          test"]
      @instance.update_entry("1.2.3.4", "test")
      @instance.save
      expect(@instance.raw_lines).to eq(expected_array)
    end

    it "properly generates file with removed content" do
      expected_array = ["", "#Some Comment", "127.0.0.1        localhost localhost.localdomain my.domain.local #with a comment"]
      @instance.update_entry("127.0.0.1", "my.domain.local")
      @instance.save
      expect(@instance.raw_lines).to eq(expected_array)
    end
  end

  describe "#hostname=" do
    it "sets the hostname using hostnamectl when the command exists" do
      new_hostname = "test-hostname"
      spawn_args = [
        @instance.cmd('hostnamectl'),
        :params => ['set-hostname', new_hostname]
      ]
      expect(@instance).to receive(:cmd?).with("hostnamectl").and_return(true)
      expect(AwesomeSpawn).to receive(:run!).with(*spawn_args)
      @instance.hostname = new_hostname
    end

    it "sets the hostname with hostname when hostnamectl does not exist" do
      new_hostname = "test-hostname"
      spawn_args = [
        @instance.cmd('hostname'),
        :params => {:file => "/etc/hostname"}
      ]
      expect(@instance).to receive(:cmd?).with("hostnamectl").and_return(false)
      expect(File).to receive(:write).with("/etc/hostname", new_hostname)
      expect(AwesomeSpawn).to receive(:run!).with(*spawn_args)
      @instance.hostname = new_hostname
    end
  end

  describe "#hostname" do
    it "returns the hostname" do
      hostname = "test-host"
      spawn_args = [
        @instance.cmd('hostname'),
        {}
      ]
      result = AwesomeSpawn::CommandResult.new("", hostname, nil, 0)
      expect(AwesomeSpawn).to receive(:run).with(*spawn_args).and_return(result)
      expect(@instance.hostname).to eq(hostname)
    end

    it "returns nil when the command fails" do
      spawn_args = [
        @instance.cmd('hostname'),
        {}
      ]
      result = AwesomeSpawn::CommandResult.new("", "", "An error has happened", 1)
      expect(AwesomeSpawn).to receive(:run).with(*spawn_args).and_return(result)
      expect(@instance.hostname).to be_nil
    end
  end
end
