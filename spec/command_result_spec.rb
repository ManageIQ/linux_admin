require 'spec_helper'

describe CommandResult do
  context "#inspect" do
    it "will not display sensitive information" do
      command_result = described_class.new("aaa", "bbb", "ccc", 0).inspect

      expect(command_result.include?("aaa")).to be_false
      expect(command_result.include?("bbb")).to be_false
      expect(command_result.include?("ccc")).to be_false
    end
  end
end