describe LinuxAdmin::Hardware do
CONTENT = <<-EOF
processor : 0
vendor_id : GenuineIntel
cpu family  : 6
model   : 58
model name  : Intel(R) Core(TM) i7-3740QM CPU @ 2.70GHz
stepping  : 9
microcode : 0x17
cpu MHz   : 2614.148
cache size  : 6144 KB
physical id : 0
siblings  : 8
core id   : 0
cpu cores : 4
apicid    : 0
initial apicid  : 0
fpu   : yes
fpu_exception : yes
cpuid level : 13
wp    : yes
flags   : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm ida arat epb pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase smep erms xsaveopt
bugs    :
bogomips  : 5387.35
clflush size  : 64
cache_alignment : 64
address sizes : 36 bits physical, 48 bits virtual
power management:

processor   : 1

processor :   2

processor : 3
processor : 4
processor : 5
processor : 6
processor : 7
EOF

  it "total_cores" do
    allow(File).to receive(:readlines).and_return(CONTENT.lines)

    expect(described_class.new.total_cores).to eq(8)
  end
end
