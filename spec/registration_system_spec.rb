shared_context "RegistrationSystem.registration_type stubbing", :registered_system_stubbing do
  def stub_registered_to_system(*system)
    allow_any_instance_of(LinuxAdmin::SubscriptionManager).to receive_messages(:registered? => system.include?(:sm))
    allow_any_instance_of(LinuxAdmin::Rhn).to receive_messages(:registered? => system.include?(:rhn))
  end
end

describe LinuxAdmin::RegistrationSystem, :registered_system_stubbing do
  context ".registration_type" do
    it "when registered Subscription Manager" do
      stub_registered_to_system(:sm)
      expect(described_class.registration_type).to eq(LinuxAdmin::SubscriptionManager)
    end

    it "when registered RHN only" do
      stub_registered_to_system(:rhn)
      expect(described_class.registration_type).to eq(LinuxAdmin::Rhn)
    end

    it "when registered both" do
      stub_registered_to_system(:sm, :rhn)
      expect(described_class.registration_type).to eq(LinuxAdmin::SubscriptionManager)
    end

    it "when unregistered" do
      stub_registered_to_system(nil)
      expect(described_class.registration_type).to eq(described_class)
    end

    it "should memoize results" do
      expect(described_class).to receive(:registration_type_uncached).once.and_return("anything_non_nil")
      described_class.registration_type
      described_class.registration_type
    end

    it "with reload should refresh results" do
      expect(described_class).to receive(:registration_type_uncached).twice.and_return("anything_non_nil")
      described_class.registration_type
      described_class.registration_type(true)
    end
  end

  context "#registered?" do
    it "when unregistered" do
      stub_registered_to_system(nil)
      expect(described_class.registered?).to be_falsey
    end

    context "SubscriptionManager" do
      it "with no args" do
        expect(LinuxAdmin::Common).to receive(:run).with("subscription-manager identity").and_return(double(:exit_status => 0))

        LinuxAdmin::SubscriptionManager.new.registered?
      end

      it "with a proxy" do
        expect(LinuxAdmin::Common).to receive(:run).with(
          "subscription-manager identity",
          :params => {
            "--proxy="         => "https://example.com",
            "--proxyuser="     => "user",
            "--proxypassword=" => "pass"
          }
        ).and_return(double(:exit_status => 0))

        LinuxAdmin::SubscriptionManager.new.registered?(
          :proxy_address  => "https://example.com",
          :proxy_username => "user",
          :proxy_password => "pass"
        )
      end
    end
  end

  context ".method_missing" do
    before do
      stub_registered_to_system(:rhn)
    end

    it "exists on the subclass" do
      expect(LinuxAdmin::RegistrationSystem.registered?).to be_truthy
    end

    it "does not exist on the subclass" do
      expect { LinuxAdmin::RegistrationSystem.organizations }.to raise_error(NotImplementedError)
    end

    it "is an unknown method" do
      expect { LinuxAdmin::RegistrationSystem.method_does_not_exist }.to raise_error(NoMethodError)
    end
  end
end

describe LinuxAdmin::SubscriptionManager, :registered_system_stubbing do
  context ".registration_type" do
    it "when registered both" do
      stub_registered_to_system(:sm, :rhn)
      expect(described_class.registration_type).to eq(LinuxAdmin::SubscriptionManager)
    end
  end
end

describe LinuxAdmin::Rhn, :registered_system_stubbing do
  context ".registration_type" do
    it "when registered both" do
      stub_registered_to_system(:sm, :rhn)
      expect(described_class.registration_type).to eq(LinuxAdmin::Rhn)
    end
  end
end
