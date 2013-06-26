# LinuxAdmin Distro Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

class LinuxAdmin
  class Distro < LinuxAdmin
    attr_accessor :id

    def initialize(id)
      @id = id
    end

    def self.local
      @local ||= begin
        if File.exists?('/etc/issue')
          issue = File.read('/etc/issue')
          if issue.include?('ubuntu')
            return Distros.ubuntu
          elsif ['Fedora', 'red hat', 'centos'].any? { |d| issue.include?(d) }
            return Distros.redhat
          end

        elsif File.exists?('/etc/redhat-release') ||
              File.exists?('/etc/fedora-release')
          return Distros.redhat
        end

        nil
      end
    end

  end

  module Distros
    def self.redhat
      @redhat ||= RedHat.new
    end

    def self.ubuntu
      @ubuntu ||= Ubuntu.new
    end

    def self.all
     @distros ||= [redhat, ubuntu]
    end

    class RedHat < Distro
      COMMANDS = {:service   => '/usr/sbin/service',
                  :systemctl => '/usr/bin/systemctl',
                  :parted    => '/usr/sbin/parted',
                  :mount     => '/usr/bin/mount',
                  :umount    => '/usr/bin/umount',
                  :shutdown  => '/usr/sbin/shutdown'}

      def initialize
        @id = :redhat
      end
    end

    class Ubuntu < Distro
      COMMANDS = {}

      def initialize
        @id = :ubuntu
      end
    end
  end
end
