module LinuxAdmin
  class Deb < Package
    APT_CACHE_CMD = '/usr/bin/apt-cache'

    def self.from_line(apt_cache_line, in_description=false)
      tag,value = apt_cache_line.split(':')
      tag = tag.strip.downcase
      [tag, value]
    end

    def self.from_string(apt_cache_string)
      in_description = false
      apt_cache_string.split("\n").each.with_object({}) do |line,deb|
        tag,value = self.from_line(line)
        if tag == 'description-en'
          in_description = true
        elsif tag == 'homepage'
          in_description = false
        end

        if in_description && tag != 'description-en'
          deb['description-en'] << line
        else
          deb[tag] = value.strip
        end
      end
    end

    def self.info(pkg)
      from_string(Common.run!(APT_CACHE_CMD, :params => ["show", pkg]).output)
    end
  end
end
