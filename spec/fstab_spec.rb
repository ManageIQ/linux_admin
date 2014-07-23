require 'stringio'

describe LinuxAdmin::FSTab do
  before do
    # Reset the singleton so subsequent tests get a new instance
    Singleton.send :__init__, LinuxAdmin::FSTab
  end

  it "has newline, single spaces, tab" do
    fstab = <<eos

  
	
eos
    expect(File).to receive(:read).with('/etc/fstab').and_return(fstab)
    expect(LinuxAdmin::FSTab.instance.entries.size).to eq(3)
    expect(LinuxAdmin::FSTab.instance.entries.any? { |e| e.has_content? }).to be_falsey
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
    entries = LinuxAdmin::FSTab.instance.entries
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
      # maually set fstab
      entry = LinuxAdmin::FSTabEntry.new
      entry.device        = '/dev/sda1'
      entry.mount_point   = '/'
      entry.fs_type       = 'ext4'
      entry.mount_options = 'defaults'
      entry.dumpable      = 1
      entry.fsck_order    = 1
      entry.comment = "# more"
      allow_any_instance_of(LinuxAdmin::FSTab).to receive(:refresh) # don't read /etc/fstab
      LinuxAdmin::FSTab.instance.maximum_column_lengths = [9, 1, 4, 8, 1, 1, 1]
      LinuxAdmin::FSTab.instance.entries  = [entry]

      expect(File).to receive(:write).with('/etc/fstab', "/dev/sda1 / ext4 defaults 1 1 # more\n")
      LinuxAdmin::FSTab.instance.write!
    end
  end
end
