module LinuxAdmin
  module Mountable
    attr_accessor :fs_type
    attr_accessor :mount_point

    module ClassMethods
      def mount_point_exists?(mount_point)
        result = Common.run!(Common.cmd(:mount))
        result.output.split("\n").any? { |line| line.split[2] == mount_point.to_s }
      end

      def mount_point_available?(mount_point)
        !mount_point_exists?(mount_point)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def discover_mount_point
      result = Common.run!(Common.cmd(:mount))
      mount_line = result.output.split("\n").find { |line| line.split[0] == path }
      @mount_point = mount_line.split[2] if mount_line
    end

    def format_to(filesystem)
      Common.run!(Common.cmd(:mke2fs),
                  :params => {'-t' => filesystem, nil => path})
      @fs_type = filesystem
    end

    def mount(mount_point)
      FileUtils.mkdir(mount_point) unless File.directory?(mount_point)

      if self.class.mount_point_exists?(mount_point)
        raise ArgumentError, "disk already mounted at #{mount_point}"
      end

      Common.run!(Common.cmd(:mount), :params => {nil => [path, mount_point]})
      @mount_point = mount_point
    end

    def umount
      Common.run!(Common.cmd(:umount), :params => {nil => [@mount_point]})
    end
  end
end
