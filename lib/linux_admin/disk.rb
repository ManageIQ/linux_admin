# LinuxAdmin Disk Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

require 'linux_admin/partition'

class LinuxAdmin
  class Disk < LinuxAdmin
    attr_accessor :path

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
            size = case $2
                   when 'K' then
                     $1.to_f.kilobytes
                   when 'M' then
                     $1.to_f.megabytes
                   when 'G' then
                     $1.to_f.gigabytes
                   end
            break
          end
        }
        size
      end
    end

    def partitions
      @partitions ||= begin
        partitions = []

        # TODO: Should this really catch non-zero RC, set output to the default "" and silently return [] ?
        #   If so, should other calls to parted also do the same?
        # requires sudo
        out = run(cmd(:parted),
                  :params => { nil => [@path, 'print'] }).output

        out.each_line do |l|
          if l =~ /^ [0-9].*/
            p = l.split
            args = {:disk => self}
            fields = [:id, :start_sector, :end_sector,
                      :size, :partition_type, :fs_type]

            fields.each_index do |i|
              val = p[i]
              case fields[i]
              when :start_sector, :end_sector, :size
                if val =~ /([0-9\.]*)([KMG])B/
                  val = case $2
                        when 'K' then
                          $1.to_f.kilobytes
                        when 'M' then
                          $1.to_f.megabytes
                        when 'G' then
                          $1.to_f.gigabytes
                        end
                end

              when :id
                val = val.to_i

              end

              args[fields[i]] = val
            end
            partitions << Partition.new(args)

          end
        end

        partitions
      end
    end

    def create_partition_table(type = "msdos")
      run!(cmd(:parted), :params => { nil => [path, "mklabel", type]})
    end

    def has_partition_table?
      result = run(cmd(:parted), :params => { nil => [path, "print"]})

      return result_indicates_missing_partition_table?(result) ? false : true
    end

    def create_partition(partition_type, size)
      create_partition_table unless has_partition_table?

      id, start =
        partitions.empty? ? [1, 0] :
          [(partitions.last.id + 1),
            partitions.last.end_sector]

      run!(cmd(:parted),
          :params => { nil => [path, 'mkpart', partition_type,
                               start, start + size]})

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

    def result_indicates_missing_partition_table?(result)
      # parted exits with 1 but writes this oddly spelled error to stdout.
      result.exit_status == 1 && result.output =~ /unrecognised disk label/
    end
  end
end
