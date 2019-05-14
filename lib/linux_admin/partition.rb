require 'fileutils'

module LinuxAdmin
  class Partition
    include Mountable

    attr_accessor :id
    attr_accessor :partition_type
    attr_accessor :start_sector
    attr_accessor :end_sector
    attr_accessor :size
    attr_accessor :disk

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
      disk.partition_path(id)
    end

    def mount(mount_point=nil)
      mount_point ||= "/mnt/#{disk.path.split(File::SEPARATOR).last}#{id}"
      super(mount_point)
    end
  end
end
