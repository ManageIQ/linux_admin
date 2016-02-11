module LinuxAdmin
  class PhysicalVolume < Volume
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

    def attach_to(vg)
      Common.run!(Common.cmd(:vgextend),
          :params => [vg.name, @device_name])
      self.volume_group = vg
      self
    end

    # specify disk or partition instance to create physical volume on
    def self.create(device)
      self.scan # initialize local physical volumes
      Common.run!(Common.cmd(:pvcreate),
          :params => { nil => device.path})
      pv  = PhysicalVolume.new(:device_name  => device.path,
                               :volume_group => nil,
                               :size => device.size)
      @pvs << pv
      pv
    end

    def self.scan
      @pvs ||= begin
        scan_volumes(Common.cmd(:pvdisplay)) do |fields, vg|
          PhysicalVolume.new(:device_name  => fields[0],
                             :volume_group => vg,
                             :size         => fields[2].to_i)
         end
      end
    end
  end
end
