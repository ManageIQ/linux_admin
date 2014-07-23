require 'spec_helper'

describe LinuxAdmin::Rhn do
  context "#registered?" do
    it "with registered system_id" do
      described_class.any_instance.stub(:systemid_file => data_file_path("rhn/systemid"))
      expect(described_class.new).to be_registered
    end

    it "with unregistered system_id" do
      described_class.any_instance.stub(:systemid_file => data_file_path("rhn/systemid.missing_system_id"))
      expect(described_class.new).to_not be_registered
    end

    it "with missing systemid file" do
      described_class.any_instance.stub(:systemid_file => data_file_path("rhn/systemid.missing_file"))
      expect(described_class.new).to_not be_registered
    end
  end

  context "#register" do
    it "no username or activation key" do
      expect { described_class.new.register({}) }.to raise_error(ArgumentError)
    end

    context "with username and password" do
      let(:base_options) { {:username       => "SomeUser@SomeDomain.org",
                            :password       => "SomePass",
                            :org            => "2",
                            :proxy_address  => "1.2.3.4",
                            :proxy_username => "ProxyUser",
                            :proxy_password => "ProxyPass",
                            :server_cert    => "/path/to/cert",
                          }
                        }
      let(:run_params) { {:params=>{"--username="=>"SomeUser@SomeDomain.org", "--password="=>"SomePass", "--proxy="=>"1.2.3.4", "--proxyUser="=>"ProxyUser", "--proxyPassword="=>"ProxyPass"}} }

      it "with server_url" do
        run_params.store_path(:params, "--systemorgid=", "2")
        run_params.store_path(:params, "--serverUrl=", "https://server.url")
        run_params.store_path(:params, "--sslCACert=", "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT")
        base_options.store_path(:server_url, "https://server.url")

        expect_any_instance_of(described_class).to receive(:run!).once.with("rhnreg_ks", run_params)
        expect(LinuxAdmin::Rpm).to receive(:upgrade).with("http://server.url/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm")
        expect(LinuxAdmin::Rpm).to receive(:list_installed).and_return({"rhn-org-trusted-ssl-cert" => "1.0"})

        described_class.new.register(base_options)
      end

      it "without server_url" do
        expect_any_instance_of(described_class).to receive(:run!).once.with("rhnreg_ks", run_params)
        expect_any_instance_of(described_class).not_to receive(:install_server_certificate)
        expect(LinuxAdmin::Rpm).to receive(:list_installed).and_return({"rhn-org-trusted-ssl-cert" => nil})

        described_class.new.register(base_options)
      end
    end

    it "with activation key" do
      expect_any_instance_of(described_class).to receive(:run!).once.with("rhnreg_ks", {:params=>{"--activationkey="=>"123abc", "--proxy="=>"1.2.3.4", "--proxyUser="=>"ProxyUser", "--proxyPassword="=>"ProxyPass"}})
      expect(LinuxAdmin::Rpm).to receive(:list_installed).and_return({"rhn-org-trusted-ssl-cert" => nil})

      described_class.new.register(
        :activationkey  => "123abc",
        :proxy_address  => "1.2.3.4",
        :proxy_username => "ProxyUser",
        :proxy_password => "ProxyPass",
      )
    end
  end

  it "#enable_channel" do
    expect_any_instance_of(described_class).to receive(:run!).once.with("rhn-channel -a", {:params=>{"--user="=>"SomeUser", "--password="=>"SomePass", "--channel="=>123}})

    described_class.new.enable_channel(123, :username => "SomeUser", :password => "SomePass")
  end

  it "#enabled_channels" do
    expect_any_instance_of(described_class).to receive(:run!).once.with("rhn-channel -l").and_return(double(:output => sample_output("rhn/output_rhn-channel_list")))

    expect(described_class.new.enabled_channels).to eq(["rhel-x86_64-server-6", "rhel-x86_64-server-6-cf-me-2"])
  end

  it "#disable_channel" do
    expect_any_instance_of(described_class).to receive(:run!).once.with("rhn-channel -r", {:params=>{"--user="=>"SomeUser", "--password="=>"SomePass", "--channel="=>123}})

    described_class.new.disable_channel(123, :username => "SomeUser", :password => "SomePass")
  end

  it "#available_channels" do
    credentials = {
      :username => "some_user",
      :password => "password"
    }
    expected    = [
      "rhel-x86_64-server-6-cf-me-2",
      "rhel-x86_64-server-6-cf-me-2-beta",
      "rhel-x86_64-server-6-cf-me-3",
      "rhel-x86_64-server-6-cf-me-3-beta"
    ]
    cmd         = "rhn-channel -L"
    params      = {
      :params => {
        "--user="     => "some_user",
        "--password=" => "password"
      }
    }

    expect_any_instance_of(described_class).to receive(:run!).once.with(cmd, params).and_return(double(:output => sample_output("rhn/output_rhn-channel_list_available")))

    expect(described_class.new.available_channels(credentials)).to eq(expected)
  end

  it "#all_repos" do
    credentials = {
      :username => "some_user",
      :password => "password"
    }
    expected = [
      {:repo_id => "rhel-x86_64-server-6-cf-me-2",      :enabled => true},
      {:repo_id => "rhel-x86_64-server-6-cf-me-2-beta", :enabled => false},
      {:repo_id => "rhel-x86_64-server-6-cf-me-3",      :enabled => false},
      {:repo_id => "rhel-x86_64-server-6-cf-me-3-beta", :enabled => false},
      {:repo_id => "rhel-x86_64-server-6",              :enabled => true}
    ]

    expect_any_instance_of(described_class).to receive(:run!).once.and_return(double(:output => sample_output("rhn/output_rhn-channel_list_available")))
    expect_any_instance_of(described_class).to receive(:run!).once.with("rhn-channel -l").and_return(double(:output => sample_output("rhn/output_rhn-channel_list")))

    expect(described_class.new.all_repos(credentials)).to eq(expected)
  end
end
