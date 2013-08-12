require 'spec_helper'

describe LinuxAdmin::Common do
  before do
    class TestClass
      extend LinuxAdmin::Common
    end
  end

  after do
    Object.send(:remove_const, :TestClass)
  end

  let(:params) do
    {
      "--user"  => "bob",
      "--pass"  => "P@$sw0^& |<>/-+*d%",
      "--db"    => nil,
      "--desc=" => "Some Description",
      nil       => ["pkg1", "some pkg"]
    }
  end

  let (:modified_params) do
    params.to_a + [123, 456].collect {|pool| ["--pool", pool]}
  end

  subject { TestClass }

  context ".write" do
    it "no file no content" do
      expect { subject.write("", "") }.to raise_error(ArgumentError)
    end
  end

  context ".cmd" do
    it "looks up local command from id" do
      d = stub(LinuxAdmin::Distro)
      d.class::COMMANDS = { :sh => '/bin/sh' }
      LinuxAdmin::Distro.should_receive(:local).and_return(d)
      subject.cmd(:sh).should == '/bin/sh'
    end
  end

  context ".run" do
    context "with params" do
      it "sanitizes crazy params" do
        subject.should_receive(:launch).once.with("true --user bob --pass P@\\$sw0\\^\\&\\ \\|\\<\\>/-\\+\\*d\\% --db --desc=Some\\ Description pkg1 some\\ pkg --pool 123 --pool 456", {})
        subject.run("true", :params => modified_params, :return_exitstatus => true)
      end

      it "as empty hash" do
        subject.should_receive(:launch).once.with("true", {})
        subject.run("true", :params => {}, :return_exitstatus => true)
      end

      it "as nil" do
        subject.should_receive(:launch).once.with("true", {})
        subject.run("true", :params => nil, :return_exitstatus => true)
      end

      it "won't modify caller params" do
        orig_params = params.dup
        subject.run("true", :params => params, :return_exitstatus => true)
        expect(orig_params).to eq(params)
      end
    end

    it "command ok exit ok" do
      expect(subject.run("true")).to be_true
    end

    it "command ok exit bad" do
      expect { subject.run("false") }.to raise_error
    end

    it "command bad" do
      expect { subject.run("XXXXX") }.to raise_error
    end

    context "with :return_exitstatus => true" do
      it "command ok exit ok" do
        expect(subject.run("true", :return_exitstatus => true)).to eq(0)
      end

      it "command ok exit bad" do
        expect(subject.run("false", :return_exitstatus => true)).to eq(1)
      end

      it "command bad" do
        expect(subject.run("XXXXX", :return_exitstatus => true)).to be_nil
      end
    end

    context "with :return_output => true" do
      it "command ok exit ok" do
        expect(subject.run("echo \"Hello World\"", :return_output => true)).to eq("Hello World\n")
      end

      it "command ok exit bad" do
        expect { subject.run("false", :return_output => true) }.to raise_error
      end

      it "command bad" do
        expect { subject.run("XXXXX", :return_output => true) }.to raise_error
      end
    end

    it "supports spawn's chdir option" do
      subject.should_receive(:launch).once.with("true", {:chdir => ".."})
      subject.run("true", :chdir => "..", :return_exitstatus => true)
    end
  end
end
