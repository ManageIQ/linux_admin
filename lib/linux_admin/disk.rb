# LinuxAdmin Disk Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

require 'linux_admin/partition'

class LinuxAdmin
  class Disk < LinuxAdmin
    PARTED_FIELDS =
      [:id, :start_sector, :end_sector,
       :size, :partition_type, :fs_type]

    attr_accessor :path

    private

    def str_to_bytes(val, unit)
      case unit
      when 'K' then
        val.to_f.kilobytes
      when 'M' then
        val.to_f.megabytes
      when 'G' then
        val.to_f.gigabytes
      end
    end

    public

    def self.local
      Dir.glob('/dev/[vhs]d[a-z]').collect do |d|
        Disk.new :path => d
      end
    end

    def initialize(args = {})
      @path = args[:path]
    end

    def size
      @size ||= begin
        size = nil
        out = run!(cmd(:fdisk), :params => {"-l" => nil}).output
        out.each_line { |l|
          if l =~ /Disk #{path}: ([0-9\.]*) ([KMG])B.*/
            size = str_to_bytes($1, $2)
            break
          end
        }
        size
      end
    end

    def partitions
      @partitions ||=
        parted_output.collect { |disk|
          partition_from_parted(disk)
        }
    end

    private

    def parted_output
      # TODO: Should this really catch non-zero RC, set output to the default "" and silently return [] ?
      #   If so, should other calls to parted also do the same?
      # requires sudo
      out = run(cmd(:parted),
                :params => { nil => parted_options_array('print') }).output
      split = []
      out.each_line do |l|
        if l =~ /^ [0-9].*/
          split << l.split
        end
      end
      split
    end


    def partition_from_parted(output_disk)
      args = {:disk => self}
      PARTED_FIELDS.each_index do |i|
        val = output_disk[i]
        case PARTED_FIELDS[i]
        when :start_sector, :end_sector, :size
          if val =~ /([0-9\.]*)([KMG])B/
            val = str_to_bytes($1, $2)
          end

        when :id
          val = val.to_i

        end
        args[PARTED_FIELDS[i]] = val
      end

      Partition.new(args)
    end

    public

    def create_partition_table(type = "msdos")
      run!(cmd(:parted), :params => { nil => parted_options_array("mklabel", type)})
    end

    def has_partition_table?
      result = run(cmd(:parted), :params => { nil => parted_options_array("print")})

      result_indicates_partition_table?(result)
    end

    def create_partition(partition_type, size)
      create_partition_table unless has_partition_table?

      id, start =
        partitions.empty? ? [1, 0] :
          [(partitions.last.id + 1),
            partitions.last.end_sector]

      options = parted_options_array('mkpart', partition_type, start, start + size)
      run!(cmd(:parted), :params => { nil => options})

      partition = Partition.new(:disk           => self,
                                :id             => id,
                                :start_sector   => start,
                                :end_sector     => start+size,
                                :size           => size,
                                :partition_type => partition_type)
      partitions << partition
      partition
    end

    def clear!
      @partitions = []

      # clear partition table
      run!(cmd(:dd),
          :params => { 'if=' => '/dev/zero', 'of=' => @path,
                       'bs=' => 512, 'count=' => 1})

      self
    end

    private

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
