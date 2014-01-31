require 'spec_helper'

describe LinuxAdmin::SubscriptionManager do
  context "#registered?" do
    it "system with subscription-manager commands" do
      described_class.any_instance.should_receive(:run).once.with("subscription-manager identity").and_return(double(:exit_status => 0))
      expect(described_class.new.registered?).to be_true
    end

    it "system without subscription-manager commands" do
      described_class.any_instance.should_receive(:run).once.with("subscription-manager identity").and_return(double(:exit_status => 255))
      expect(described_class.new.registered?).to be_false
    end
  end

  it "#refresh" do
    described_class.any_instance.should_receive(:run!).once.with("subscription-manager refresh")
    described_class.new.refresh
  end

  context "#register" do
    it "no username" do
      expect { described_class.new.register }.to raise_error(ArgumentError)
    end

    context "with username and password" do
      let(:base_options) { {:username       => "SomeUser@SomeDomain.org",
                            :password       => "SomePass",
                            :org            => "IT",
                            :proxy_address  => "1.2.3.4",
                            :proxy_username => "ProxyUser",
                            :proxy_password => "ProxyPass",
                          }
                        }
      let(:run_params) { {:params=>{"--username="=>"SomeUser@SomeDomain.org", "--password="=>"SomePass", "--proxy="=>"1.2.3.4", "--proxyuser="=>"ProxyUser", "--proxypassword="=>"ProxyPass"}} }

      it "with server_url" do
        run_params.store_path(:params, "--org=", "IT")
        run_params.store_path(:params, "--serverurl=", "https://server.url")
        base_options.store_path(:server_url, "https://server.url")

        described_class.any_instance.should_receive(:run!).once.with("subscription-manager register", run_params)
        LinuxAdmin::Rpm.should_receive(:upgrade).with("http://server.url/pub/candlepin-cert-consumer-latest.noarch.rpm")

        described_class.new.register(base_options)
      end

      it "without server_url" do
        described_class.any_instance.should_receive(:run!).once.with("subscription-manager register", run_params)
        described_class.any_instance.should_not_receive(:install_server_certificate)

        described_class.new.register(base_options)
      end
    end
  end

  context "#subscribe" do
    it "with pools" do
      described_class.any_instance.should_receive(:run!).once.with("subscription-manager attach", {:params=>[["--pool", 123], ["--pool", 456]]})
      described_class.new.subscribe({:pools => [123, 456]})
    end

    it "without pools" do
      described_class.any_instance.should_receive(:run!).once.with("subscription-manager attach", {:params=>{"--auto"=>nil}})
      described_class.new.subscribe({})
    end
  end

  context "#subscribed_products" do
    it "subscribed" do
      described_class.any_instance.should_receive(:run!).once.with("subscription-manager list --installed").and_return(double(:output => sample_output("subscription_manager/output_list_installed_subscribed")))
      expect(described_class.new.subscribed_products).to eq(["69", "167"])
    end

    it "not subscribed" do
      described_class.any_instance.should_receive(:run!).once.with("subscription-manager list --installed").and_return(double(:output => sample_output("subscription_manager/output_list_installed_not_subscribed")))
      expect(described_class.new.subscribed_products).to eq(["167"])
    end
  end

  it "#available_subscriptions" do
    described_class.any_instance.should_receive(:run!).once.with("subscription-manager list --all --available").and_return(double(:output => sample_output("subscription_manager/output_list_all_available")))
    expect(described_class.new.available_subscriptions).to eq({
      "82c042fca983889b10178893f29b06e3" => {
        :subscription_name => "Example Subscription",
        :sku               => "SER0123",
        :pool_id           => "82c042fca983889b10178893f29b06e3",
        :quantity          => "1690",
        :service_level     => "None",
        :service_type      => "None",
        :multi_entitlement => "No",
        :ends              => Date.parse("2022-01-01"),
        :system_type       => "Physical",
      },
      "4f738052ec866192c775c62f408ab868" => {
        :subscription_name => "My Private Subscription",
        :sku               => "SER9876",
        :pool_id           => "4f738052ec866192c775c62f408ab868",
        :quantity          => "Unlimited",
        :service_level     => "None",
        :service_type      => "None",
        :multi_entitlement => "No",
        :ends              => Date.parse("2013-06-04"),
        :system_type       => "Virtual",
      },
      "3d81297f352305b9a3521981029d7d83" => {
        :subscription_name => "Shared Subscription - With other characters, (2 sockets) (Up to 1 guest)",
        :sku               => "RH0123456",
        :pool_id           => "3d81297f352305b9a3521981029d7d83",
        :quantity          => "1",
        :service_level     => "Self-support",
        :service_type      => "L1-L3",
        :multi_entitlement => "No",
        :ends              => Date.parse("2013-05-15"),
        :system_type       => "Virtual",
      },
      "87cefe63b67984d5c7e401d833d2f87f" => {
        :subscription_name => "Example Subscription, Premium (up to 2 sockets) 3 year",
        :sku               => "MCT0123A9",
        :pool_id           => "87cefe63b67984d5c7e401d833d2f87f",
        :quantity          => "1",
        :service_level     => "Premium",
        :service_type      => "L1-L3",
        :multi_entitlement => "No",
        :ends              => Date.parse("2013-07-05"),
        :system_type       => "Virtual",
      },
    })
  end

  context "#organizations" do
    it "with valid credentials" do
      run_options = ["subscription-manager orgs", {:params=>{"--username="=>"SomeUser", "--password="=>"SomePass", "--proxy="=>"1.2.3.4", "--proxyuser="=>"ProxyUser", "--proxypassword="=>"ProxyPass", "--serverurl="=>"192.168.1.1"}}]

      LinuxAdmin::Rpm.should_receive(:upgrade).with("http://192.168.1.1/pub/candlepin-cert-consumer-latest.noarch.rpm")
      described_class.any_instance.should_receive(:run!).once.with(*run_options).and_return(double(:output => sample_output("subscription_manager/output_orgs")))

      expect(described_class.new.organizations({:username=>"SomeUser", :password=>"SomePass", :proxy_address=>"1.2.3.4", :proxy_username=>"ProxyUser", :proxy_password=>"ProxyPass", :server_url=>"192.168.1.1"})).to eq({"SomeOrg"=>{:name=>"SomeOrg", :key=>"1234567"}})
    end

    it "with invalid credentials" do
      run_options = ["subscription-manager orgs", {:params=>{"--username="=>"BadUser", "--password="=>"BadPass"}}]
      described_class.any_instance.should_receive(:run).once.with(*run_options).and_return(CommandResult.new("", "", "Invalid username or password. To create a login, please visit https://www.redhat.com/wapps/ugc/register.html", 255))
      expect { described_class.new.organizations({:username=>"BadUser", :password=>"BadPass"}) }.to raise_error(LinuxAdmin::CredentialError)
    end
  end

  it "#enable_repo" do
    described_class.any_instance.should_receive(:run!).once.with("subscription-manager repos", {:params=>{"--enable="=>"abc"}})

    described_class.new.enable_repo("abc")
  end

  it "#disable_repo" do
    described_class.any_instance.should_receive(:run!).once.with("subscription-manager repos", {:params=>{"--disable="=>"abc"}})

    described_class.new.disable_repo("abc")
  end

  it "#all_repos" do
    expected = [
      {
        :repo_id   => "some-repo-source-rpms",
        :repo_name => "Some Repo (Source RPMs)",
        :repo_url  => "https://my.host.example.com/repos/some-repo/source/rpms",
        :enabled   => true
      },
      {
        :repo_id   => "some-repo-rpms",
        :repo_name => "Some Repo",
        :repo_url  => "https://my.host.example.com/repos/some-repo/rpms",
        :enabled   => true
      },
      {
        :repo_id   => "some-repo-2-beta-rpms",
        :repo_name => "Some Repo (Beta RPMs)",
        :repo_url  => "https://my.host.example.com/repos/some-repo-2/beta/rpms",
        :enabled   => false
      }
    ]

    described_class.any_instance.should_receive(:run!).once.with("subscription-manager repos").and_return(double(:output => sample_output("subscription_manager/output_repos")))

    expect(described_class.new.all_repos).to eq(expected)
  end
end
