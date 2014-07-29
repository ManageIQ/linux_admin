# LinuxAdmin Logical Volume Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

class LinuxAdmin
  class Volume < LinuxAdmin
    private

    def self.process_volume_display_line(line)
      groups = VolumeGroup.scan
      fields = line.split(':')
      vgname = fields[1]
      vg = groups.find { |g| g.name == vgname }
      return fields, vg
    end

    protected

    def self.scan_volumes(cmd)
      volumes = []

      out = run!(cmd, :params => { '-c' => nil}).output

      out.each_line do |line|
        fields, vg = process_volume_display_line(line.lstrip)
        volumes << yield(fields, vg)
      end

      volumes
    end
  end
end
