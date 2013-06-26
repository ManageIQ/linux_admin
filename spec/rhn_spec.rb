require 'spec_helper'

describe LinuxAdmin::Rhn do
  it ".systemid_file" do
    expect(described_class.systemid_file).to be_kind_of(String)
  end

  context ".registered?" do
    it "with registered system_id" do
      described_class.stub(:systemid_file => data_file_path("rhn/systemid"))
      expect(described_class).to be_registered
    end

    it "with unregistered system_id" do
      described_class.stub(:systemid_file => data_file_path("rhn/systemid.missing_system_id"))
      expect(described_class).to_not be_registered
    end

    it "with missing systemid file" do
      described_class.stub(:systemid_file => data_file_path("rhn/systemid.missing_file"))
      expect(described_class).to_not be_registered
    end
  end

  context ".register" do
    it "no username or activation key" do
      expect { described_class.register({}) }.to raise_error(ArgumentError)
    end

    it "with username and password" do
      described_class.should_receive(:run).once.with("rhnreg_ks", {:params=>{"--username="=>"SomeUser", "--password="=>"SomePass", "--proxy="=>"1.2.3.4", "--proxyUser="=>"ProxyUser", "--proxyPassword="=>"ProxyPass", "--serverUrl="=>"192.168.1.1"}}).and_return(0)
      described_class.register(
        :username       => "SomeUser",
        :password       => "SomePass",
        :proxy_address  => "1.2.3.4",
        :proxy_username => "ProxyUser",
        :proxy_password => "ProxyPass",
        :server_url     => "192.168.1.1",
      )
    end

    it "with activation key" do
      described_class.should_receive(:run).once.with("rhnreg_ks", {:params=>{"--activationkey="=>"123abc", "--proxy="=>"1.2.3.4", "--proxyUser="=>"ProxyUser", "--proxyPassword="=>"ProxyPass", "--serverUrl="=>"192.168.1.1"}}).and_return(0)
      described_class.register(
        :activationkey  => "123abc",
        :proxy_address  => "1.2.3.4",
        :proxy_username => "ProxyUser",
        :proxy_password => "ProxyPass",
        :server_url     => "192.168.1.1",
      )
    end
  end

  context ".subscribe" do
    it "without arguments" do
      expect { described_class.subscribe({}) }.to raise_error(ArgumentError)
    end

    it "with pools" do
      described_class.should_receive(:run).once.with("rhn-channel -a", {:params=>[["--user=", "SomeUser"], ["--password=", "SomePass"], ["--channel=", 123], ["--channel=", 456]]})
      described_class.subscribe({
        :username => "SomeUser",
        :password => "SomePass",
        :pools    => [123, 456]
        })
    end
  end
end