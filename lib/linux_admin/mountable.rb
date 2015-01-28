# LinuxAdmin Mountable Disk Mixin
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

module LinuxAdmin
  module Mountable
    attr_accessor :fs_type
    attr_accessor :mount_point
    include Common

    module ClassMethods
      include Common

      def mount_point_exists?(mount_point)
        result = run!(cmd(:mount))
        result.output.split("\n").any? { |line| line.split[2] == mount_point }
      end

      def mount_point_available?(mount_point)
        !mount_point_exists?(mount_point)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def format_to(filesystem)
      run!(cmd(:mke2fs),
          :params => { '-t' => filesystem, nil => self.path})
      @fs_type = filesystem
    end

    def mount(mount_point)
      FileUtils.mkdir(mount_point) unless File.directory?(mount_point)

      if self.class.mount_point_exists?(mount_point)
        raise ArgumentError, "disk already mounted at #{mount_point}"
      end

      run!(cmd(:mount), :params => { nil => [self.path, mount_point] })
      @mount_point = mount_point
    end

    def umount
      run!(cmd(:umount), :params => { nil => [@mount_point] })
    end
  end
end
