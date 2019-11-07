require 'linux_admin/partition'

module LinuxAdmin
  class Disk
    PARTED_FIELDS =
      [:id, :start_sector, :end_sector,
       :size, :partition_type, :fs_type]

    attr_accessor :path, :model

    # Collect local disk information via the lsblk command. Only disks with a
    # size greater than zero are returned.
    #
    def self.local
      result = Common.run!(Common.cmd("lsblk"), :params => {:b => nil, :d => nil, :n => nil, :p => nil, :o => "NAME,SIZE,TYPE,MODEL"})
      result.output.split("\n").collect do |string|
        path, size, type, *model = string.split
        if type.casecmp?('disk') && size.to_i > 0
          self.new(:path => path, :size => size.to_i, :model => model.join(' '))
        end
      end.compact
    end

    def initialize(args = {})
      @path  = args[:path]
      @model = args[:model] || "unknown"
      @size  = args[:size]
    end

    def size
      @size ||= begin
        size = nil
        out = Common.run!(Common.cmd(:fdisk), :params => {"-l" => nil}).output
        out.each_line do |l|
          /Disk #{path}: .*B, (\d+) bytes/.match(l) do |m|
            size = m[1].to_i
            break
          end
        end
        size
      end
    end

    def partitions
      @partitions ||=
        parted_output.collect { |disk|
          partition_from_parted(disk)
        }
    end

    def create_partition_table(type = "msdos")
      Common.run!(Common.cmd(:parted), :params => {nil => parted_options_array("mklabel", type)})
    end

    def has_partition_table?
      result = Common.run(Common.cmd(:parted), :params => {nil => parted_options_array("print")})

      result_indicates_partition_table?(result)
    end

    def create_partition(partition_type, *args)
      create_partition_table unless has_partition_table?

      start = finish = size = nil
      case args.length
      when 1 then
        start  = partitions.empty? ? 0 : partitions.last.end_sector
        size   = args.first
        finish = start + size

      when 2 then
        start  = args[0]
        finish = args[1]

      else
        raise ArgumentError, "must specify start/finish or size"
      end

      id = partitions.empty? ? 1 : (partitions.last.id + 1)
      options = parted_options_array('mkpart', '-a', 'opt', partition_type, start, finish)
      Common.run!(Common.cmd(:parted), :params => {nil => options})

      partition = Partition.new(:disk           => self,
                                :id             => id,
                                :start_sector   => start,
                                :end_sector     => finish,
                                :size           => size,
                                :partition_type => partition_type)
      partitions << partition
      partition
    end

    def create_partitions(partition_type, *args)
      check_if_partitions_overlap(args)

      args.each { |arg|
        self.create_partition(partition_type, arg[:start], arg[:end])
      }
    end

    def clear!
      @partitions = []

      # clear partition table
      Common.run!(Common.cmd(:dd),
          :params => { 'if=' => '/dev/zero', 'of=' => @path,
                       'bs=' => 512, 'count=' => 1})

      self
    end

    def partition_path(id)
      case model
      when "nvme"
        "#{path}p#{id}"
      else
        "#{path}#{id}"
      end
    end

    private

    def str_to_bytes(val, unit)
      case unit
      when 'K', 'k' then
        val.to_f * 1_024 # 1.kilobytes
      when 'M' then
        val.to_f * 1_048_576 # 1.megabyte
      when 'G' then
        val.to_f * 1_073_741_824 # 1.gigabytes
      end
    end

    def overlapping_ranges?(ranges)
      ranges.find do |range1|
        ranges.any? do |range2|
          range1 != range2 &&
            ranges_overlap?(range1, range2)
        end
      end
    end

    def ranges_overlap?(range1, range2) # copied from activesupport Range#overlaps?
      range1.cover?(range2.first) || range2.cover?(range1.first)
    end

    def check_if_partitions_overlap(partitions)
      ranges =
        partitions.collect do |partition|
          start  = partition[:start]
          finish = partition[:end]
          start.delete('%')
          finish.delete('%')
          start.to_f..finish.to_f
        end

      if overlapping_ranges?(ranges)
        raise ArgumentError, "overlapping partitions"
      end
    end

    def parted_output
      # TODO: Should this really catch non-zero RC, set output to the default "" and silently return [] ?
      #   If so, should other calls to parted also do the same?
      # requires sudo
      out = Common.run(Common.cmd(:parted),
                :params => { nil => parted_options_array('print') }).output
      split = []
      out.each_line do |l|
        if l =~ /^ [0-9].*/
          split << l.split
        elsif l =~ /^Model:.*/
          parse_model(l)
        end
      end
      split
    end

    def parse_model(parted_line)
      matches = parted_line.match(/^Model:.*\((?<model>\w+)\)$/)
      @model = matches[:model] if matches
    end

    def partition_from_parted(output_disk)
      args = {:disk => self}
      PARTED_FIELDS.each_index do |i|
        val = output_disk[i]
        case PARTED_FIELDS[i]
        when :start_sector, :end_sector, :size
          if val =~ /([0-9\.]*)([kKMG])B/
            val = str_to_bytes($1, $2)
          end

        when :id
          val = val.to_i

        end
        args[PARTED_FIELDS[i]] = val
      end

      Partition.new(args)
    end

    def parted_options_array(*args)
      args = args.first if args.first.kind_of?(Array)
      parted_default_options + args
    end

    def parted_default_options
      @parted_default_options ||= ['--script', path].freeze
    end

    def result_indicates_partition_table?(result)
      # parted exits with 1 but writes this oddly spelled error to stdout.
      missing = (result.exit_status == 1 && result.output.include?("unrecognised disk label"))
      !missing
    end
  end
end
