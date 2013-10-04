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

  it ".upgrade" do
    described_class.should_receive(:run!).with("rpm -U", {:params=>{nil=>"abc"}}).and_return(CommandResult.new("", "", 0))
    expect(described_class.upgrade("abc")).to be_true
  end
end