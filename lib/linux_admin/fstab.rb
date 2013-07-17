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
      write('/etc/fstab', content)
      self
    end

    private

    def refresh
      @entries = []
      f = File.read('/etc/fstab')
      f.each_line { |line|
        first_char = line.strip[0] 
        if first_char != '#' && first_char !~ /\s/
          columns = line.split
          entry   = FSTabEntry.new
          entry.device         = columns[0]
          entry.mount_point    = columns[1]
          entry.fs_type        = columns[2]
          entry.mount_options  = columns[3]
          entry.dumpable       = columns[4].to_i
          entry.fsck_order     = columns[5].to_i
          @entries << entry
        end
      }
      self
    end
  end
end
