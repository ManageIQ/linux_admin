require 'spec_helper'

describe LinuxAdmin::Common do
  context ".run" do
    it "command ok exit ok" do
      expect(described_class.run("true")).to be_true
    end

    it "command ok exit bad" do
      expect { described_class.run("false") }.to raise_error
    end

    it "command bad" do
      expect { described_class.run("XXXXX") }.to raise_error
    end

    context "with :return_exitstatus => true" do
      it "command ok exit ok" do
        expect(described_class.run("true", :return_exitstatus => true)).to eq(0)
      end

      it "command ok exit bad" do
        expect(described_class.run("false", :return_exitstatus => true)).to eq(1)
      end

      it "command bad" do
        expect(described_class.run("XXXXX", :return_exitstatus => true)).to be_nil
      end
    end
  end
end