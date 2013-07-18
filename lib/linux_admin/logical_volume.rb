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
                  :params => { '-c' => nil})

        out.each_line do |line|
          fields = line.split(':')
          vgname = fields[1] 
          vg = vgs.find { |vg| vg.name == vgname }

          lvs << LogicalVolume.new(:name         => fields[0],
                                   :volume_group => vg,
                                   :sectors      => fields[6].to_i)
        end

        lvs
      end
    end
  end
end
