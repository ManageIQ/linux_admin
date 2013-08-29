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
          elsif ['Fedora', 'red hat', 'Red Hat', 'centos'].any? { |d| issue.include?(d) }
            return Distros.redhat
          end

        elsif File.exists?('/etc/redhat-release') ||
              File.exists?('/etc/fedora-release')
          return Distros.redhat
        end

        Distros.generic
      end
    end

  end

  module Distros
    def self.generic
      @generic ||= Generic.new
    end

    def self.redhat
      @redhat ||= RedHat.new
    end

    def self.ubuntu
      @ubuntu ||= Ubuntu.new
    end

    def self.all
     @distros ||= [generic, redhat, ubuntu]
    end

    class Generic < Distro
      COMMANDS = {}

      def initialize
        @id = :generic
      end
    end

    class RedHat < Distro
      COMMANDS = {:service   => '/sbin/service',
                  :chkconfig => '/sbin/chkconfig',
                  :parted    => '/sbin/parted',
                  :mount     => '/bin/mount',
                  :umount    => '/bin/umount',
                  :shutdown  => '/sbin/shutdown',
                  :mke2fs    => '/sbin/mke2fs',
                  :fdisk     => '/sbin/fdisk',
                  :dd        => '/bin/dd',
                  :vgdisplay => '/sbin/vgdisplay',
                  :pvdisplay => '/sbin/pvdisplay',
                  :lvdisplay => '/sbin/lvdisplay',
                  :lvextend  => '/sbin/lvextend',
                  :vgextend  => '/sbin/vgextend',
                  :lvcreate  => '/sbin/lvcreate',
                  :pvcreate  => '/sbin/pvcreate',
                  :vgcreate  => '/sbin/vgcreate'}

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
