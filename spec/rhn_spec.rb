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
end