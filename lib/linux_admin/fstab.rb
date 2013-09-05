# LinuxAdmin fstab Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

require 'singleton'

class LinuxAdmin
  class FSTabEntry < LinuxAdmin
    attr_accessor :device
    attr_accessor :mount_point
    attr_accessor :fs_type
    attr_accessor :mount_options
    attr_accessor :dumpable
    attr_accessor :fsck_order

    def initialize(args = {})
      @device        = args[:device]
      @mount_point   = args[:mount_point]
      @fs_type       = args[:fs_type]
      @mount_options = args[:mount_options]
      @dumpable      = args[:dumpable]
      @fsck_order    = args[:fsck_order]
    end

    def self.from_line(fstab_line)
      columns = fstab_line.chomp.split
      FSTabEntry.new :device        => columns[0],
                     :mount_point   => columns[1],
                     :fs_type       => columns[2],
                     :mount_options => columns[3],
                     :dumpable      => columns[4].to_i,
                     :fsck_order    => columns[5].to_i
      
    end
  end

  class FSTab < LinuxAdmin
    include Singleton

    attr_accessor :entries

    def initialize
      refresh
    end

    def write!
      content = ''
      @entries.each do |entry|
        content += "#{entry.device} #{entry.mount_point} #{entry.fs_type} #{entry.mount_options} #{entry.dumpable} #{entry.fsck_order}\n"
      end
      File.write('/etc/fstab', content)
      self
    end

    private

    def read
      File.read('/etc/fstab').lines.find_all {|line| !line.blank? && !line.strip.starts_with?("#")}
    end

    def refresh
      @entries = 
        read.collect { |line|
          FSTabEntry.from_line line
        }
    end
  end
end
