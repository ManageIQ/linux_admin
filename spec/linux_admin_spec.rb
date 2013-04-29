require 'spec_helper'

describe LinuxAdmin do
  context ".registered?" do
    it "when registered Subscription Manager" do
      stub_registered_to_system(:sm)
      expect(described_class.registered?).to be_true
    end

    it "when registered RHN" do
      stub_registered_to_system(:rhn)
      expect(described_class.registered?).to be_true
    end

    it "when unregistered" do
      stub_registered_to_system(nil)
      expect(described_class.registered?).to be_false
    end
  end

  context ".registration_type" do
    it "when registered Subscription Manager" do
      stub_registered_to_system(:sm)
      expect(described_class.registration_type).to eq(LinuxAdmin::SubscriptionManager)
    end

    it "when registered RHN" do
      stub_registered_to_system(:rhn)
      expect(described_class.registration_type).to eq(LinuxAdmin::Rhn)
    end

    it "when unregistered" do
      stub_registered_to_system(nil)
      expect(described_class.registration_type).to be_nil
    end
  end

  def stub_registered_to_system(system)
    described_class::SubscriptionManager.stub(:registered? => (system == :sm))
    described_class::Rhn.stub(:registered? => (system == :rhn))
  end
end