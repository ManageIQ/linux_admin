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

  describe "#update_ip_for_hostname" do
    it "updates an existing entry" do
      expected_hash = [
        {:blank => true},
        {:comment => "Some Comment"},
        {:address => "127.0.0.1",
         :hosts   => [
           "localhost",
           "localhost.localdomain"
         ],
         :comment => "with a comment"
        },
        {:address => "192.168.1.10",
         :hosts   => ["my.domain.local"]
        }
      ]
      @instance.update_ip_for_hostname("my.domain.local", "192.168.1.10")
      expect(@instance.parsed_file).to eq(expected_hash)
    end

    it "creates a new entry if none match" do
      expected_hash = [
        {:blank => true},
        {:comment => "Some Comment"},
        {:address => "127.0.0.1",
         :hosts   => [
           "localhost",
           "localhost.localdomain"
         ],
         :comment => "with a comment"
        },
        {:address => "127.0.1.1",
         :hosts   => ["my.domain.local"]
        },
        {:address => "192.168.1.10",
         :hosts   => ["new.domain.local"],
         :comment => nil
        }
      ]
      @instance.update_ip_for_hostname("new.domain.local", "192.168.1.10")
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
      spawn_args = [
        @instance.cmd('hostnamectl'),
        :params => ['set-hostname', TEST_HOSTNAME]
      ]
      expect(@instance).to receive(:cmd?).with("hostnamectl").and_return(true)
      expect(AwesomeSpawn).to receive(:run!).with(*spawn_args)
      @instance.hostname = TEST_HOSTNAME
    end

    it "sets the hostname with hostname when hostnamectl does not exist" do
      spawn_args = [
        @instance.cmd('hostname'),
        :params => {:file => "/etc/hostname"}
      ]
      expect(@instance).to receive(:cmd?).with("hostnamectl").and_return(false)
      expect(File).to receive(:write).with("/etc/hostname", TEST_HOSTNAME)
      expect(AwesomeSpawn).to receive(:run!).with(*spawn_args)
      @instance.hostname = TEST_HOSTNAME
    end
  end

  describe "#hostname" do
    let(:spawn_args) do
      [@instance.cmd('hostname'), {}]
    end

    it "returns the hostname" do
      result = AwesomeSpawn::CommandResult.new("", TEST_HOSTNAME, nil, 0)
      expect(AwesomeSpawn).to receive(:run).with(*spawn_args).and_return(result)
      expect(@instance.hostname).to eq(TEST_HOSTNAME)
    end

    it "returns nil when the command fails" do
      result = AwesomeSpawn::CommandResult.new("", "", "An error has happened", 1)
      expect(AwesomeSpawn).to receive(:run).with(*spawn_args).and_return(result)
      expect(@instance.hostname).to be_nil
    end
  end
end
