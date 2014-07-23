require 'spec_helper'

describe LinuxAdmin::RegistrationSystem do
  context ".registration_type" do
    it "when registered Subscription Manager" do
      stub_registered_to_system(:sm)
      expect(described_class.registration_type).to eq(LinuxAdmin::SubscriptionManager)
    end

    it "when registered RHN" do
      stub_registered_to_system(:sm, :rhn)
      expect(described_class.registration_type).to eq(LinuxAdmin::Rhn)
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

  it "#registered? when unregistered" do
    stub_registered_to_system(nil)
    expect(described_class.registered?).to be_falsey
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

  def stub_registered_to_system(*system)
    allow_any_instance_of(LinuxAdmin::SubscriptionManager).to receive_messages(:registered? => (system.include?(:sm)))
    allow_any_instance_of(LinuxAdmin::Rhn).to receive_messages(:registered? => (system.include?(:rhn)))
  end
end
