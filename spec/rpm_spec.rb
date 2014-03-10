require 'spec_helper'

describe LinuxAdmin::Rpm do
  it ".list_installed" do
    described_class.stub(:run! => double(:output => sample_output("rpm/cmd_output_for_list_installed")))
    expect(described_class.list_installed).to eq({
      "ruby193-rubygem-some_really_long_name" =>"1.0.7-1.el6",
      "fipscheck-lib"                         =>"1.2.0-7.el6",
      "aic94xx-firmware"                      =>"30-2.el6",
      "latencytop-common"                     =>"0.5-9.el6",
      "uuid"                                  =>"1.6.1-10.el6",
      "ConsoleKit"                            =>"0.4.1-3.el6",
      "cpuspeed"                              =>"1.5-19.el6",
      "mailcap"                               =>"2.1.31-2.el6",
      "freetds"                               =>"0.82-7.1.el6cf",
      "elinks"                                =>"0.12-0.21.pre5.el6_3",
      "abrt-cli"                              =>"2.0.8-15.el6",
      "libattr"                               =>"2.4.44-7.el6",
      "passwd"                                =>"0.77-4.el6_2.2",
      "vim-enhanced"                          =>"7.2.411-1.8.el6",
      "popt"                                  =>"1.13-7.el6",
      "hesiod"                                =>"3.1.0-19.el6",
      "pinfo"                                 =>"0.6.9-12.el6",
      "libpng"                                =>"1.2.49-1.el6_2",
      "libdhash"                              =>"0.4.2-9.el6",
      "zlib-devel"                            =>"1.2.3-29.el6",
      })
  end

  it ".import_key" do
    described_class.should_receive(:run!).with("rpm", {:params => {"--import" => "abc"}})
    expect { described_class.import_key("abc") }.to_not raise_error
  end

  describe "#info" do
    it "returns package metadata" do
      # as output w/ rpm -qi ruby on F19
      data = <<EOS
Name        : ruby
Version     : 2.0.0.247
Release     : 15.fc19
Architecture: x86_64
Install Date: Sat 19 Oct 2013 08:17:20 PM EDT
Group       : Development/Languages
Size        : 64473
License     : (Ruby or BSD) and Public Domain
Signature   : RSA/SHA256, Thu 01 Aug 2013 02:07:03 PM EDT, Key ID 07477e65fb4b18e6
Source RPM  : ruby-2.0.0.247-15.fc19.src.rpm
Build Date  : Wed 31 Jul 2013 08:26:49 AM EDT
Build Host  : buildvm-16.phx2.fedoraproject.org
Relocations : (not relocatable)
Packager    : Fedora Project
Vendor      : Fedora Project
URL         : http://ruby-lang.org/
Summary     : An interpreter of object-oriented scripting language
Description :
Ruby is the interpreted scripting language for quick and easy
object-oriented programming.  It has many features to process text
files and to do system management tasks (as in Perl).  It is simple,
straight-forward, and extensible.
EOS
      arguments = [described_class.rpm_cmd, :params => {"-qi" => "ruby"}]
      result = AwesomeSpawn::CommandResult.new("", data, "", 0)
      described_class.should_receive(:run!).with(*arguments).and_return(result)
      metadata = described_class.info("ruby")
      metadata['name'].should == 'ruby'
      metadata['version'].should == '2.0.0.247'
      metadata['release'].should == '15.fc19'
      metadata['architecture'].should == 'x86_64'
      metadata['group'].should == 'Development/Languages'
      metadata['size'].should == '64473'
      metadata['license'].should == '(Ruby or BSD) and Public Domain'
      metadata['source_rpm'].should == 'ruby-2.0.0.247-15.fc19.src.rpm'
      metadata['build_host'].should == 'buildvm-16.phx2.fedoraproject.org'
      metadata['packager'].should == 'Fedora Project'
      metadata['vendor'].should == 'Fedora Project'
      metadata['summary'].should == 'An interpreter of object-oriented scripting language'
    end
  end

  it ".upgrade" do
    described_class.should_receive(:run).with("rpm -U", {:params=>{nil=>"abc"}}).and_return(double(:exit_status => 0))
    expect(described_class.upgrade("abc")).to be_true
  end
end
