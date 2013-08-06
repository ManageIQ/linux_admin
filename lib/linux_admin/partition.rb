# LinuxAdmin Partition Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

require 'fileutils'

class LinuxAdmin
  class Partition < LinuxAdmin
    attr_accessor :id
    attr_accessor :partition_type
    attr_accessor :fs_type
    attr_accessor :start_sector
    attr_accessor :end_sector
    attr_accessor :size
    attr_accessor :disk
    attr_accessor :mount_point

    def initialize(args={})
      @id      = args[:id]
      @size    = args[:size]
      @disk    = args[:disk]
      @fs_type = args[:fs_type]
      @start_sector   = args[:start_sector]
      @end_sector     = args[:end_sector]
      @partition_type = args[:partition_type]
    end

    def path
      "#{disk.path}#{id}"
    end

    def format_to(filesystem)
      run(cmd(:mke2fs),
          :params => { '-t' => filesystem, nil => self.path})
      @fs_type = filesystem
    end

    def mount(mount_point=nil)
      @mount_point = mount_point
      @mount_point  =
        "/mnt/#{disk.path.split(File::SEPARATOR).last}#{id}" if mount_point.nil?
      FileUtils.mkdir(@mount_point) unless File.directory?(@mount_point)

      run(cmd(:mount),
          :params => { nil => [self.path, @mount_point] })
    end

    def umount
      run(cmd(:umount),
          :params => { nil => [@mount_point] })
    end
  end
end
