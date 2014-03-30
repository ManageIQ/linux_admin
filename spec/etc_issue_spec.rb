require 'spec_helper'
require 'stringio'

describe LinuxAdmin::EtcIssue do
  subject { described_class.instance }
  before do
    # Reset the singleton so subsequent tests get a new instance
    subject.refresh
  end

  it "should not find the phrase when the file is missing" do
    expect(File).to receive(:exists?).with('/etc/issue').at_least(:once).and_return(false)
    expect(subject).not_to include("phrase")
  end

  it "should not find phrase when the file is empty" do
    etc_issue_contains("")
    expect(subject).not_to include("phrase")
  end

  it "should not find phrase when the file has a different phrase" do
    etc_issue_contains("something\nelse")
    expect(subject).not_to include("phrase")
  end

  it "should find phrase in same case" do
    etc_issue_contains("phrase")
    expect(subject).to include("phrase")
  end

  it "should find upper phrase in file" do
    etc_issue_contains("PHRASE\nother")
    expect(subject).to include("phrase")
  end

  it "should find phrase when searching with upper" do
    etc_issue_contains("other\nphrase")
    expect(subject).to include("PHRASE")
  end
end
