require 'spec_helper'

describe LinuxAdmin::SubscriptionManager do
  context ".registered?" do
    it "system with subscription-manager commands" do
      described_class.should_receive(:run).once.with("subscription-manager identity", {:return_exitstatus=>true}).and_return(0)
      expect(described_class.registered?).to be_true
    end

    it "system without subscription-manager commands" do
      described_class.should_receive(:run).once.with("subscription-manager identity", {:return_exitstatus=>true}).and_return(255)
      expect(described_class.registered?).to be_false
    end
  end

  it ".refresh" do
    described_class.should_receive(:run).once.with("subscription-manager refresh").and_return(0)
    described_class.refresh
  end

  context ".register" do
    it "no username" do
      expect { described_class.register }.to raise_error(ArgumentError)
    end

    it "with username and password" do
      described_class.should_receive(:run).once.with("subscription-manager register", {:params=>{"--username="=>"SomeUser", "--password="=>"SomePass", "--org="=>"IT", "--proxy="=>"1.2.3.4", "--proxyuser="=>"ProxyUser", "--proxypassword="=>"ProxyPass", "--serverurl="=>"192.168.1.1"}}).and_return(0)
      described_class.register(
        :username       => "SomeUser",
        :password       => "SomePass",
        :org            => "IT",
        :proxy_address  => "1.2.3.4",
        :proxy_username => "ProxyUser",
        :proxy_password => "ProxyPass",
        :server_url     => "192.168.1.1",
      )
    end
  end

  it ".subscribe" do
    described_class.should_receive(:run).once.with("subscription-manager attach", {:params=>[["--pool", 123], ["--pool", 456]]})
    described_class.subscribe({:pools => [123, 456]})
  end

  it ".available_subscriptions" do
    described_class.should_receive(:run).once.with("subscription-manager list --all --available", :return_output => true).and_return(sample_output("subscription_manager/output_list_all_available"))
    expect(described_class.available_subscriptions).to eq({
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
end
