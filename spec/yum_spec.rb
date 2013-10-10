require 'spec_helper'

describe LinuxAdmin::Yum do
  before(:each) do
    FileUtils.stub(:mkdir_p => true)
  end

  context ".create_repo" do
    it "default arguments" do
      described_class.should_receive(:run!).once.with("createrepo", {:params=>{nil=>"some/path", "--database"=>nil, "--unique-md-filenames"=>nil}})
      described_class.create_repo("some/path")
    end

    it "bare create" do
      described_class.should_receive(:run!).once.with("createrepo", {:params=>{nil=>"some/path"}})
      described_class.create_repo("some/path", :database => false, :unique_file_names => false)
    end
  end

  context ".download_packages" do
    it "with valid input" do
      described_class.should_receive(:run!).once.with("repotrack", {:params=>{"-p"=>"some/path", nil=>"pkg_a pkg_b"}})
      described_class.download_packages("some/path", "pkg_a pkg_b")
    end

    it "without mirror type" do
      expect { described_class.download_packages("some/path", "pkg_a pkg_b", :mirror_type => nil) }.to raise_error(ArgumentError)
    end
  end

  it ".repo_settings" do
    described_class.should_receive(:parse_repo_dir).once.with("/etc/yum.repos.d").and_return(true)
    expect(described_class.repo_settings).to be_true
  end

  it ".parse_repo_dir" do
    expect(described_class.parse_repo_dir(data_file_path("yum"))).to eq({
      File.join(data_file_path("yum"), "first.repo")  =>
        { "my-local-repo-a"   =>
          { "name"            =>"My Local Repo A",
            "baseurl"         =>"https://mirror.example.com/a/content/os_ver",
            "enabled"         =>0,
            "gpgcheck"        =>1,
            "gpgkey"          =>"file:///etc/pki/rpm-gpg/RPM-GPG-KEY-my-local-server",
            "sslverify"       =>1,
            "sslcacert"       =>"/etc/rhsm/ca/my-loacl-server.pem",
            "sslclientkey"    =>"/etc/pki/entitlement/0123456789012345678-key.pem",
            "sslclientcert"   =>"/etc/pki/entitlement/0123456789012345678.pem",
            "metadata_expire" =>86400},
          "my-local-repo-b" =>
          { "name"            =>"My Local Repo B",
            "baseurl"         =>"https://mirror.example.com/b/content/os_ver",
            "enabled"         =>1,
            "gpgcheck"        =>0,
            "sslverify"       =>0,
            "metadata_expire" =>86400}},
      File.join(data_file_path("yum"), "second.repo") =>
        { "my-local-repo-c" =>
          { "name"            =>"My Local Repo c",
            "baseurl"         =>"https://mirror.example.com/c/content/os_ver",
            "enabled"         =>0,
            "cost"            =>100,
            "gpgcheck"        =>1,
            "gpgkey"          =>"file:///etc/pki/rpm-gpg/RPM-GPG-KEY-my-local-server",
            "sslverify"       =>0,
            "metadata_expire" =>1}},})
  end

  context ".updates_available?" do
    it "check updates for a specific package" do
      described_class.should_receive(:run).once.with("yum check-update", {:params=>{nil=>["abc"]}}).and_return(double(:exit_status => 100))
      expect(described_class.updates_available?("abc")).to be_true
    end

    it "updates are available" do
      described_class.stub(:run => double(:exit_status => 100))
      expect(described_class.updates_available?).to be_true
    end

    it "updates not available" do
      described_class.stub(:run => double(:exit_status => 0))
      expect(described_class.updates_available?).to be_false
    end

    it "other exit code" do
      described_class.stub(:run => double(:exit_status => 255))
      expect { described_class.updates_available? }.to raise_error
    end

    it "other error" do
      described_class.stub(:run).and_raise(RuntimeError)
      expect { described_class.updates_available? }.to raise_error(RuntimeError)
    end
  end

  context ".update" do
    it "no arguments" do
      described_class.should_receive(:run!).once.with("yum -y update", {:params=>nil})
      described_class.update
    end

    it "with arguments" do
      described_class.should_receive(:run!).once.with("yum -y update", {:params=>{nil=>["1 2", "3"]}})
      described_class.update("1 2", "3")
    end
  end

  context ".version_available" do
    it "no packages" do
      expect { described_class.version_available }.to raise_error(ArgumentError)
    end

    it "with one package" do
      described_class.should_receive(:run!).once.with("repoquery --qf=\"%{name} %{version}\"", {:params=>{nil=>["subscription-manager"]}}).and_return(double(:output => sample_output("yum/output_repoquery_single")))
      expect(described_class.version_available("subscription-manager")).to eq({"subscription-manager" => "1.1.23.1"})
    end

    it "with multiple packages" do
      described_class.should_receive(:run!).once.with("repoquery --qf=\"%{name} %{version}\"", {:params=>{nil=>["curl", "subscription-manager", "wget"]}}).and_return(double(:output => sample_output("yum/output_repoquery_multiple")))
      expect(described_class.version_available("curl", "subscription-manager", "wget")).to eq({
        "curl"                  => "7.19.7",
        "subscription-manager"  => "1.1.23.1",
        "wget"                  => "1.12"
      })
    end
  end
end