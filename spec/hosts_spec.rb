describe LinuxAdmin::Hosts do
  TEST_HOSTNAME = "test-hostname"
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

  describe "#set_loopback_hostname" do
    etc_hosts_v6_loopback = <<-EOT

#Some Comment
::1\tlocalhost localhost.localdomain # with a comment
127.0.0.1\tlocalhost localhost.localdomain # with a comment
127.0.1.1  my.domain.local
EOT

    before do
      allow(File).to receive(:read).and_return(etc_hosts_v6_loopback)
      @instance_v6_loopback = LinuxAdmin::Hosts.new
    end

    it "adds the hostname to the start of the hosts list for the loopback addresses" do
      expected_hash = [{:blank   => true},
                       {:comment => "Some Comment"},
                       {:address => "::1",
                        :hosts   => ["examplehost.example.com", "localhost", "localhost.localdomain"],
                        :comment => "with a comment"},
                       {:address => "127.0.0.1",
                        :hosts   => ["examplehost.example.com", "localhost", "localhost.localdomain"],
                        :comment => "with a comment"},
                       {:address => "127.0.1.1", :hosts => ["my.domain.local"]}]
      @instance_v6_loopback.set_loopback_hostname("examplehost.example.com")
      expect(@instance_v6_loopback.parsed_file).to eq(expected_hash)
    end
  end

  describe "#set_canonical_hostname" do
    it "removes an existing entry and creates a new one" do
      expected_hash = [{:blank => true},
                       {:comment => "Some Comment"},
                       {:address => "127.0.0.1", :hosts => ["localhost", "localhost.localdomain"], :comment => "with a comment"},
                       {:address => "127.0.1.1", :hosts => []},
                       {:address => "1.2.3.4", :hosts => ["my.domain.local"], :comment => nil}]
      @instance.set_canonical_hostname("1.2.3.4", "my.domain.local")
      expect(@instance.parsed_file).to eq(expected_hash)
    end

    it "adds the hostname to the start of the hosts list" do
      expected_hash = [{:blank => true},
                       {:comment => "Some Comment"},
                       {:address => "127.0.0.1", :hosts => ["examplehost.example.com", "localhost", "localhost.localdomain"], :comment => "with a comment"},
                       {:address => "127.0.1.1", :hosts => ["my.domain.local"]}]
      @instance.set_canonical_hostname("127.0.0.1", "examplehost.example.com")
      expect(@instance.parsed_file).to eq(expected_hash)
    end
  end

  describe "#save" do
    it "properly generates file with new content" do
      allow(File).to receive(:write)
      expected_array = ["", "#Some Comment", "127.0.0.1        localhost localhost.localdomain #with a comment", "127.0.1.1        my.domain.local", "1.2.3.4          test"]
      @instance.update_entry("1.2.3.4", "test")
      @instance.save
      expect(@instance.raw_lines).to eq(expected_array)
    end

    it "properly generates file with removed content" do
      allow(File).to receive(:write)
      expected_array = ["", "#Some Comment", "127.0.0.1        localhost localhost.localdomain my.domain.local #with a comment"]
      @instance.update_entry("127.0.0.1", "my.domain.local")
      @instance.save
      expect(@instance.raw_lines).to eq(expected_array)
    end

    it "ends the file with a new line" do
      expect(File).to receive(:write) do |_file, contents|
        expect(contents).to end_with("\n")
      end
      @instance.save
    end
  end

  describe "#hostname=" do
    it "sets the hostname using hostnamectl when the command exists" do
      spawn_args = [
        LinuxAdmin::Common.cmd('hostnamectl'),
        :params => ['set-hostname', TEST_HOSTNAME]
      ]
      expect(LinuxAdmin::Common).to receive(:cmd?).with("hostnamectl").and_return(true)
      expect(AwesomeSpawn).to receive(:run!).with(*spawn_args)
      @instance.hostname = TEST_HOSTNAME
    end

    it "sets the hostname with hostname when hostnamectl does not exist" do
      spawn_args = [
        LinuxAdmin::Common.cmd('hostname'),
        :params => {:file => "/etc/hostname"}
      ]
      expect(LinuxAdmin::Common).to receive(:cmd?).with("hostnamectl").and_return(false)
      expect(File).to receive(:write).with("/etc/hostname", TEST_HOSTNAME)
      expect(AwesomeSpawn).to receive(:run!).with(*spawn_args)
      @instance.hostname = TEST_HOSTNAME
    end
  end

  describe "#hostname" do
    let(:spawn_args) do
      [LinuxAdmin::Common.cmd('hostname'), {}]
    end

    it "returns the hostname" do
      result = AwesomeSpawn::CommandResult.new("", TEST_HOSTNAME, "", 55, 0)
      expect(AwesomeSpawn).to receive(:run).with(*spawn_args).and_return(result)
      expect(@instance.hostname).to eq(TEST_HOSTNAME)
    end

    it "returns nil when the command fails" do
      result = AwesomeSpawn::CommandResult.new("", "", "An error has happened", 55, 1)
      expect(AwesomeSpawn).to receive(:run).with(*spawn_args).and_return(result)
      expect(@instance.hostname).to be_nil
    end
  end
end
