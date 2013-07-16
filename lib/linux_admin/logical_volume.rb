# LinuxAdmin Logical Volume Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

class LinuxAdmin
  class LogicalVolume < LinuxAdmin
    # logical volume name
    attr_accessor :name

    # volume group name
    attr_accessor :volume_group

    # logical volume size in sectors
    attr_accessor :sectors

    # other fields available:
    # logical volume access
    # logical volume status
    # internal logical volume number
    # open count of logical volume
    # current logical extents associated to logical volume
    # allocated logical extents of logical volume
    # allocation policy of logical volume
    # read ahead sectors of logical volume
    # major device number of logical volume
    # minor device number of logical volume

    def initialize(args = {})
      @name         = args[:name]
      @volume_group = args[:volume_group]
      @sectors      = args[:sectors]
    end

    def self.scan
      @lvs ||= begin
        vgs = VolumeGroup.scan
        lvs = []

        out = run(cmd(:lvdisplay),
                  :return_output => true,
                  :params => { nil => ['-c']})

        out.each_line do |line|
          fields = line.split(':')
          vgname = fields[1] 
          vg = vgs.find { |vg| vg.name == vgname }

          lvs << LogicalVolume.new(:name         => fields[0],
                                   :volume_group =>        vg,
                                   :sectors      => fields[6].to_i)
        end

        lvs
      end
    end
  end

  class PhysicalVolume < LinuxAdmin
    # physical volume device name
    attr_accessor :device_name

    # volume group name
    attr_accessor :volume_group

    # physical volume size in kilobytes
    attr_accessor :size

    # other fields available
    # internal physical volume number (obsolete)
    # physical volume status
    # physical volume (not) allocatable
    # current number of logical volumes on this physical volume
    # physical extent size in kilobytes
    # total number of physical extents
    # free number of physical extents
    # allocated number of physical extents

    def initialize(args = {})
      @device_name  = args[:device_name]
      @volume_group = args[:volume_group]
      @size         = args[:size]
    end

    def self.scan
      @pvs ||= begin
        vgs = VolumeGroup.scan
        pvs = []

        out = run(cmd(:pvdisplay),
                  :return_output => true,
                  :params => { nil => ['-c']})

        out.each_line do |line|
          fields = line.split(':')
          vgname = fields[1]
          vg = vgs.find { |vg| vg.name == vgname}

          pvs << PhysicalVolume.new(:device_name  => fields[0],
                                    :volume_group =>        vg,
                                    :size         => fields[2].to_i)
        end

        pvs
      end
    end
  end

  class VolumeGroup < LinuxAdmin
    # volume group name
    attr_accessor :name

    # other fields available
    # volume group access
    # volume group status
    # internal volume group number
    # maximum number of logical volumes
    # current number of logical volumes
    # open count of all logical volumes in this volume group
    # maximum logical volume size
    # maximum number of physical volumes
    # current number of physical volumes
    # actual number of physical volumes
    # size of volume group in kilobytes
    # physical extent size
    # total number of physical extents for this volume group
    # allocated number of physical extents for this volume group
    # free number of physical extents for this volume group
    # uuid of volume group

    def initialize(args = {})
      @name   = args[:name]
    end

    def self.scan
      @vgs ||= begin
        vgs = []

        out = run(cmd(:vgdisplay),
                  :return_output => true,
                  :params => { nil => ['-c']})

        out.each_line do |line|
          fields = line.split(':')
          vgs << VolumeGroup.new(:name   => fields[0])
        end

        vgs
      end
    end
  end
end
