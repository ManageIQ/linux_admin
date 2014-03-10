# LinuxAdmin /etc/issue Representation
#
# Copyright (C) 2014 Red Hat Inc.
# Licensed under the MIT License

require 'singleton'

class LinuxAdmin
  class EtcIssue
    include Singleton

    PATH = '/etc/issue'

    def initialize
      refresh
    end

    def to_s
      @data.to_s
    end

    private

    def refresh
      @data = File.exists?(PATH) ? File.read(PATH) : ""
    end
  end
end
