describe LinuxAdmin::FSTab do
  subject { described_class.dup }

  it "has newline, single spaces, tab" do
    fstab = <<eos

  
	
eos
    expect(File).to receive(:read).with('/etc/fstab').and_return(fstab)
    expect(subject.instance.entries.size).to eq(3)
    expect(subject.instance.entries.any?(&:has_content?)).to be_falsey
  end

  it "creates FSTabEntry for each line in fstab" do
    fstab = <<eos
# Comment, indented comment, comment with device information
  # /dev/sda1 / ext4  defaults  1 1
# /dev/sda1 / ext4  defaults  1 1

/dev/sda1 / ext4  defaults  1 1
/dev/sda2 swap  swap  defaults  0 0
eos
    expect(File).to receive(:read).with('/etc/fstab').and_return(fstab)
    entries = subject.instance.entries
    expect(entries.size).to eq(6)

    expect(entries[0].comment).to eq("# Comment, indented comment, comment with device information\n")
    expect(entries[1].comment).to eq("# /dev/sda1 / ext4  defaults  1 1\n")
    expect(entries[2].comment).to eq("# /dev/sda1 / ext4  defaults  1 1\n")
    expect(entries[3].comment).to eq(nil)
    expect(entries[4].device).to eq('/dev/sda1')
    expect(entries[4].mount_point).to eq('/')
    expect(entries[4].fs_type).to eq('ext4')
    expect(entries[4].mount_options).to eq('defaults')
    expect(entries[4].dumpable).to eq(1)
    expect(entries[4].fsck_order).to eq(1)

    expect(entries[5].device).to eq('/dev/sda2')
    expect(entries[5].mount_point).to eq('swap')
    expect(entries[5].fs_type).to eq('swap')
    expect(entries[5].mount_options).to eq('defaults')
    expect(entries[5].dumpable).to eq(0)
    expect(entries[5].fsck_order).to eq(0)
  end

  describe "#write!" do
    it "writes entries to /etc/fstab" do
      expect(File).to receive(:read).with("/etc/fstab").and_return("")

      subject.instance.entries << LinuxAdmin::FSTabEntry.new(
        :device        => '/dev/sda1',
        :mount_point   => '/',
        :fs_type       => 'ext4',
        :mount_options => 'defaults',
        :dumpable      => 1,
        :fsck_order    => 1,
        :comment       => "# more"
      )

      expect(File).to receive(:write).with('/etc/fstab', "/dev/sda1 / ext4 defaults 1 1 # more\n")

      subject.instance.write!
    end
  end

  describe "integration test" do
    it "input equals output, just alignment changed" do
      original_fstab = <<~END_OF_FSTAB

        #
        # /etc/fstab
        # Created by anaconda on Wed May 29 12:37:40 2019
        #
        # Accessible filesystems, by reference, are maintained under '/dev/disk'
        # See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
        #
        /dev/mapper/VG--MIQ-lv_os /                       xfs     defaults        0 0
        UUID=02bf07b5-2404-4779-b93c-d8eb7f2eedea /boot                   xfs     defaults        0 0
        /dev/mapper/VG--MIQ-lv_home /home                   xfs     defaults        0 0
        /dev/mapper/VG--MIQ-lv_tmp /tmp                    xfs     defaults        0 0
        /dev/mapper/VG--MIQ-lv_var /var                    xfs     defaults        0 0
        /dev/mapper/VG--MIQ-lv_var_log /var/log                xfs     defaults        0 0
        /dev/mapper/VG--MIQ-lv_var_log_audit /var/log/audit          xfs     defaults        0 0
        /dev/mapper/VG--MIQ-lv_log /var/www/miq/vmdb/log   xfs     defaults        0 0
        /dev/mapper/VG--MIQ-lv_swap swap                    swap    defaults        0 0
      END_OF_FSTAB

      new_fstab = <<~END_OF_FSTAB

        # /etc/fstab
        # Created by anaconda on Wed May 29 12:37:40 2019

        # Accessible filesystems, by reference, are maintained under '/dev/disk'
        # See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info

                        /dev/mapper/VG--MIQ-lv_os                     /  xfs defaults 0 0
        UUID=02bf07b5-2404-4779-b93c-d8eb7f2eedea                 /boot  xfs defaults 0 0
                      /dev/mapper/VG--MIQ-lv_home                 /home  xfs defaults 0 0
                       /dev/mapper/VG--MIQ-lv_tmp                  /tmp  xfs defaults 0 0
                       /dev/mapper/VG--MIQ-lv_var                  /var  xfs defaults 0 0
                   /dev/mapper/VG--MIQ-lv_var_log              /var/log  xfs defaults 0 0
             /dev/mapper/VG--MIQ-lv_var_log_audit        /var/log/audit  xfs defaults 0 0
                       /dev/mapper/VG--MIQ-lv_log /var/www/miq/vmdb/log  xfs defaults 0 0
                      /dev/mapper/VG--MIQ-lv_swap                  swap swap defaults 0 0
      END_OF_FSTAB

      expect(File).to receive(:read).with("/etc/fstab").and_return(original_fstab)
      expect(File).to receive(:write).with("/etc/fstab", new_fstab)

      subject.instance.write!
    end
  end
end
