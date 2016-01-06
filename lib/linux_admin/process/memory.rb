module LinuxAdmin
  module Process
    class Memory
      attr_reader :pss, :rss, :uss, :shared, :swap, :size

      def initialize(pid = Process.pid, smaps = nil)
        @pss    = 0
        @rss    = 0
        @uss    = 0
        @shared = 0
        @swap   = 0
        @size   = 0
        @smaps_data = smaps || smaps_data(pid)
        parse_smaps
      end

      def smaps_data(pid)
        smaps = "/proc/#{pid}/smaps"
        raise "smaps not found: #{smaps}" unless File.exist?(smaps)
        File.read(smaps)
      end

      private

      def parse_smaps
        @smaps_data.each_line do |line|
          parse_smaps_line(line)
        end
      end

      def parse_smaps_line(line)
        case line
        when /^Pss:\s+([\d]+)/
          @pss += Regexp.last_match[-1].to_i
        when /^Rss:\s+([\d]+)/
          @rss += Regexp.last_match[-1].to_i
        when /^Size:\s+([\d]+)/
          @size += Regexp.last_match[-1].to_i
        when /^Swap:\s+([\d]+)/
          @swap += Regexp.last_match[-1].to_i
        when /^Private_(Clean|Dirty):\s+([\d]+)/
          @uss += Regexp.last_match[-1].to_i
        when /^Shared_(Clean|Dirty):\s+([\d]+)/
          @shared += Regexp.last_match[-1].to_i
        end
      end
    end
  end
end
