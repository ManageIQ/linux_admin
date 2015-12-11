module LinuxAdmin
  class VolumeGroup
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

    def attach_to(lv)
      Common.run!(Common.cmd(:lvextend),
                  :params => [lv.name, name])
      self
    end

    def extend_with(pv)
      Common.run!(Common.cmd(:vgextend),
                  :params => [@name, pv.device_name])
      pv.volume_group = self
      self
    end

    def self.create(name, pv)
      self.scan # initialize local volume groups
      Common.run!(Common.cmd(:vgcreate),
                  :params => [name, pv.device_name])
      vg = VolumeGroup.new :name => name
      pv.volume_group = vg
      @vgs << vg
      vg
    end

    def self.scan
      @vgs ||= begin
        vgs = []

        out = Common.run!(Common.cmd(:vgdisplay), :params => {'-c' => nil}).output

        out.each_line do |line|
          fields = line.lstrip.split(':')
          vgs << VolumeGroup.new(:name => fields[0])
        end

        vgs
      end
    end
  end
end
