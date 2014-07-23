describe LinuxAdmin::System do
  describe "#reboot!" do
    it "reboots the system" do
      expect(LinuxAdmin::System).to receive(:run!).
         with(LinuxAdmin::System.cmd(:shutdown),
              :params => { '-r' => 'now'})
      LinuxAdmin::System.reboot!
    end
  end

  describe "#shutdown!" do
    it "shuts down the system" do
      expect(LinuxAdmin::System).to receive(:run!).
         with(LinuxAdmin::System.cmd(:shutdown),
              :params => { '-h' => '0'})
      LinuxAdmin::System.shutdown!
    end
  end
end
