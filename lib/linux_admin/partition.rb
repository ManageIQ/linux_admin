# LinuxAdmin Partition Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

require 'fileutils'

class LinuxAdmin
  class Partition < LinuxAdmin
    attr_accessor :id
    attr_accessor :fs_type
    attr_accessor :size
    attr_accessor :disk
    attr_accessor :mount_point

    def initialize(args={})
      @id      = args[:id]
      @size    = args[:size]
      @disk    = args[:disk]
      @fs_type = args[:fs_type]
    end

    def path
      "#{disk.path}#{id}"
    end

    def mount(mount_point=nil)
      @mount_point = mount_point
      @mount_point  =
        "/mnt/#{disk.path.split(File::SEPARATOR).last}#{id}" if mount_point.nil?
      FileUtils.mkdir(@mount_point) unless File.directory?(@mount_point)

      run(cmd(:mount),
          :params => { nil => [self.path, @mount_point] })
    end

    def unmount
      run(cmd(:umount),
          :params => { nil => [@mount_point] })
    end

    def format_to(fs_type)
      #TODO
    end
  end
end
