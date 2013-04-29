require 'nokogiri'

module LinuxAdmin
  module Rhn
    def self.systemid_file
      "/etc/sysconfig/rhn/systemid"
    end

    def self.registered?
      id = ""
      if File.exists?(systemid_file)
        xml = Nokogiri.XML(File.read(systemid_file))
        id = xml.xpath('/params/param/value/struct/member[name="system_id"]/value/string').text
      end
      id.length > 0
    end
  end
end