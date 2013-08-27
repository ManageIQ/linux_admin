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

  context ".cmd" do
    it "looks up local command from id" do
      d = double(LinuxAdmin::Distro)
      d.class::COMMANDS = {:sh => '/bin/sh'}
      LinuxAdmin::Distro.should_receive(:local).and_return(d)
      subject.cmd(:sh).should == '/bin/sh'
    end
  end

  shared_examples_for "run" do
    context "with params" do
      before do
        subject.stub(:exitstatus => 0)
      end

      it "sanitizes crazy params" do
        subject.should_receive(:launch).once.with("true --user bob --pass P@\\$sw0\\^\\&\\ \\|\\<\\>/-\\+\\*d\\% --db --desc=Some\\ Description pkg1 some\\ pkg --pool 123 --pool 456", {})
        subject.send(run_method, "true", :params => modified_params)
      end

      it "sanitizes fixnum array params" do
        subject.should_receive(:launch).once.with("true 1", {})
        subject.send(run_method, "true", :params => { nil => [1]})
      end

      it "as empty hash" do
        subject.should_receive(:launch).once.with("true", {})
        subject.send(run_method, "true", :params => {})
      end

      it "as nil" do
        subject.should_receive(:launch).once.with("true", {})
        subject.send(run_method, "true", :params => nil)
      end

      it "won't modify caller params" do
        orig_params = params.dup
        subject.stub(:launch)
        subject.send(run_method, "true", :params => params)
        expect(orig_params).to eq(params)
      end

      it "supports spawn's chdir option" do
        subject.should_receive(:launch).once.with("true", {:chdir => ".."})
        subject.send(run_method, "true", :chdir => "..")
      end
    end

    context "with real execution" do
      before do
        Kernel.stub(:spawn).and_call_original
      end

      it "command ok exit ok" do
        expect(subject.send(run_method, "true")).to be_kind_of CommandResult
      end

      it "command ok exit bad" do
        if run_method == "run!"
          error = nil

          # raise_error with do/end block notation is broken in rspec-expectations 2.14.x
          # and has been fixed in master but not yet released.
          # See: https://github.com/rspec/rspec-expectations/commit/b0df827f4c12870aa4df2f20a817a8b01721a6af
          expect {subject.send(run_method, "false")}.to raise_error {|e| error = e }
          expect(error).to be_kind_of CommandResultError
          expect(error.result).to be_kind_of CommandResult
        else
          expect {subject.send(run_method, "false")}.to_not raise_error
        end
      end

      it "command bad" do
        expect {subject.send(run_method, "XXXXX --user=bob")}.to raise_error(LinuxAdmin::NoSuchFileError, "No such file or directory - XXXXX")
      end

      context "#exit_status" do
        it "command ok exit ok" do
          expect(subject.send(run_method, "true").exit_status).to eq(0)
        end

        it "command ok exit bad" do
          expect(subject.send(run_method, "false").exit_status).to eq(1) if run_method == "run"
        end
      end

      context "#output" do
        it "command ok exit ok" do
          expect(subject.send(run_method, "echo \"Hello World\"").output).to eq("Hello World\n")
        end

        it "command ok exit bad" do
          expect(subject.send(run_method, "echo 'bad' && false").output).to eq("bad\n") if run_method == "run"
        end
      end

      context "#error" do
        it "command ok exit ok" do
          expect(subject.send(run_method, "echo \"Hello World\" >&2").error).to eq("Hello World\n")
        end

        it "command ok exit bad" do
          expect(subject.send(run_method, "echo 'bad' >&2 && false").error).to eq("bad\n") if run_method == "run"
        end
      end
    end
  end

  context ".run" do
    include_examples "run" do
      let(:run_method) {"run"}
    end
  end

  context ".run!" do
    include_examples "run" do
      let(:run_method) {"run!"}
    end
  end
end
