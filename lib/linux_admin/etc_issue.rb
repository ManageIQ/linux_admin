# LinuxAdmin /etc/issue Representation
#
# Copyright (C) 2014 Red Hat Inc.
# Licensed under the MIT License

require 'singleton'

module LinuxAdmin
  class EtcIssue
    include Singleton

    PATH = '/etc/issue'

    def include?(osname)
      data.downcase.include?(osname.to_s.downcase)
    end

    def data
      @data ||= File.exist?(PATH) ? File.read(PATH) : ""
    end

    def refresh
      @data = nil
    end
  end
end
