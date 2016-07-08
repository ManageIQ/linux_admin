require 'pathname'

module LinuxAdmin
  class LogicalVolume < Volume
    include Mountable

    DEVICE_PATH  = Pathname.new('/dev/')

    # logical volume name
    attr_reader :name

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

    # path to logical volume
    def path
      "/dev/#{self.volume_group.name}/#{self.name}"
    end

    def path=(value)
      @path = value.include?(File::SEPARATOR) ? value : DEVICE_PATH.join(@volume_group.name, value)
    end

    def name=(value)
      @name = value.include?(File::SEPARATOR) ? value.split(File::SEPARATOR).last : value
    end

    def initialize(args = {})
      @volume_group = args[:volume_group]
      @sectors      = args[:sectors]
      provided_name = args[:name].to_s
      self.path     = provided_name
      self.name     = provided_name
    end

    def extend_with(vg)
      Common.run!(Common.cmd(:lvextend),
          :params => [self.name, vg.name])
      self
    end

    private

    def self.bytes_to_string(bytes)
      if bytes > 1_073_741_824 # 1.gigabytes
        (bytes / 1_073_741_824).to_s + "G"
      elsif bytes > 1_048_576 # 1.megabytes
        (bytes / 1_048_576).to_s + "M"
      elsif bytes > 1_024 # 1.kilobytes
        (bytes / 1_024).to_s + "K"
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
      Common.run!(Common.cmd(:lvcreate), :params => params)

      lv = LogicalVolume.new(:name => name,
                             :volume_group => vg,
                             :sectors => size)
      @lvs << lv
      lv
    end

    def self.scan
      @lvs ||= begin
        scan_volumes(Common.cmd(:lvdisplay)) do |fields, vg|
          LogicalVolume.new(:name         => fields[0],
                            :volume_group => vg,
                            :sectors      => fields[6].to_i)
        end
      end
    end
  end
end
