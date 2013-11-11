require 'spec_helper'

describe LinuxAdmin::Deb do
  describe "#info" do
    it "returns package metadata" do
      # as output w/ apt-cache show ruby on ubuntu 13.04
      data = <<EOS
Package: ruby
Priority: optional
Section: interpreters
Installed-Size: 31
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Original-Maintainer: akira yamada <akira@debian.org>
Architecture: all
Source: ruby-defaults
Version: 4.9
Replaces: irb, rdoc
Provides: irb, rdoc
Depends: ruby1.9.1 (>= 1.9.3.194-1)
Suggests: ri, ruby-dev
Conflicts: irb, rdoc
Filename: pool/main/r/ruby-defaults/ruby_4.9_all.deb
Size: 4896
MD5sum: b1991f2e0eafb04f5930ed242cfe1476
SHA1: a7c55fbb83dd8382631ea771b5555d989351f840
SHA256: 84d042e0273bd2f0082dd9e7dda0246267791fd09607041a35485bfff92f38d9
Description-en: Interpreter of object-oriented scripting language Ruby (default version)
 Ruby is the interpreted scripting language for quick and easy
 object-oriented programming.  It has many features to process text
 files and to do system management tasks (as in perl).  It is simple,
 straight-forward, and extensible.
 .
 This package is a dependency package, which depends on Debian's default Ruby
 version (currently v1.9.3).
Homepage: http://www.ruby-lang.org/
Description-md5: da2991b37e3991230d79ba70f9c01682
Bugs: https://bugs.launchpad.net/ubuntu/+filebug
Origin: Ubuntu
Supported: 9m
Task: kubuntu-desktop, kubuntu-full, kubuntu-active, kubuntu-active-desktop, kubuntu-active-full, kubuntu-active, edubuntu-desktop-gnome, ubuntustudio-font-meta
EOS
      described_class.should_receive(:run).
                      with(described_class::APT_CACHE_CMD, :params => ["show", "ruby"]).
                      and_return(CommandResult.new("", data, "", 0))
      metadata = described_class.info("ruby")
      metadata['package'].should == 'ruby'
      metadata['priority'].should == 'optional'
      metadata['section'].should == 'interpreters'
      metadata['architecture'].should == 'all'
      metadata['version'].should == '4.9'
      metadata['origin'].should == 'Ubuntu'
    end
  end
end
