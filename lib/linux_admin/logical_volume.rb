# LinuxAdmin Logical Volume Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

class LinuxAdmin
  class LogicalVolume < Volume
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

    def extend_with(vg)
      run!(cmd(:lvextend),
          :params => [self.name, vg.name])
      self
    end

    private

    def self.bytes_to_string(bytes)
      if bytes > 1.gigabytes
        (bytes / 1.gigabytes).to_s + "G"
      elsif bytes > 1.megabytes
        (bytes / 1.megabytes).to_s + "M"
      elsif bytes > 1.kilobytes
        (bytes / 1.kilobytes).to_s + "K"
      else
        bytes.to_s
      end
    end

    public

    def self.create(name, vg, value)
      self.scan # initialize local logical volumes
      params = { '-n' => name, nil => vg.name}
      size = nil
      if value <= 100
        # size = # TODO size from extents
        params.merge!({'-l' => "#{value}%FREE"})
      else
        size = value
        params.merge!({'-L' => bytes_to_string(size)})
      end
      run!(cmd(:lvcreate), :params => params)
      lv = LogicalVolume.new :name => name,
                             :volume_group => vg,
                             :sectors => size
      @lvs << lv
      lv
    end

    def self.scan
      @lvs ||= begin
        scan_volumes(cmd(:lvdisplay)) do |fields, vg|
          LogicalVolume.new(:name         => fields[0],
                            :volume_group => vg,
                            :sectors      => fields[6].to_i)
        end
      end
    end
  end
end
