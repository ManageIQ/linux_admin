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

    def partitions
      @partitions ||= begin
        partitions = []

        # requires sudo
        out = run(cmd(:parted),
                  :return_exitstatus => true,
                  :return_output => true,
                  :params => { nil => [@path, 'print'] })

        return [] if out.kind_of?(Fixnum)

        out.each_line do |l|
          if l =~ /^ [0-9].*/
            p = l.split
            id,size,fs_type = p[0], p[3], p[5]
            if size =~ /([0-9\.]*)([KMG])B/
              size = case $2
                     when 'K' then
                       $1.to_f.kilobytes
                     when 'M' then
                       $1.to_f.megabytes
                     when 'G' then
                       $1.to_f.gigabytes
                     end
            end
            partitions << Partition.new(:disk => self,
                                        :id => id.to_i,
                                        :size => size,
                                        :fs_type => fs_type)
          end
        end

        partitions
      end
    end

    def create_partition
      # TODO
    end
  end
end
