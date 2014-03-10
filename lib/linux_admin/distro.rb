# LinuxAdmin Distro Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

require 'linux_admin/etc_issue'

class LinuxAdmin
  module Distros
    def self.generic
      @generic ||= Generic.new
    end

    def self.redhat
      @redhat ||= RedHat.new
    end

    def self.rhel
      @rhel ||= RHEL.new
    end

    def self.fedora
      @fedora ||= Fedora.new
    end

    def self.ubuntu
      @ubuntu ||= Ubuntu.new
    end

    def self.all
     @distros ||= [generic, redhat, ubuntu]
    end

    def self.local
      Distro.local
    end

    class Distro
      RELEASE_FILE = ''
      ETC_ISSUE_KEYWORDS = []

      def self.etc_issue_keywords
        self::ETC_ISSUE_KEYWORDS
      end

      def self.release_file
        self::RELEASE_FILE
      end

      def self.local
        # this can be cleaned up..
        @local ||= begin
          result = nil
          Distros.constants.each do |cdistro|
            distro_method = cdistro.to_s.downcase.to_sym
            distro = Distros.const_get(cdistro)
            next unless distro < Distro
            result = Distros.send(distro_method) if distro.detected?
          end
          result || Distros.generic
        end
      end

      def self.detected?
        detected_by_etc_issue? || detected_by_etc_release?
      end

      def self.detected_by_etc_issue?
        etc_issue_keywords.any? { |k| EtcIssue.instance.to_s.include?(k) }
      end

      def self.detected_by_etc_release?
        File.exists?(release_file)
      end
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

    class RHEL < RedHat
      RELEASE_FILE =       "/etc/redhat-release"
      ETC_ISSUE_KEYWORDS = ['red hat', 'Red Hat', 'centos', 'CentOS']

      COMMANDS = COMMANDS.merge(
                   :rpm => '/bin/rpm'
                 )
      def initialize
        @id = :rhel
      end
    end

    class Fedora < RedHat
      RELEASE_FILE =       "/etc/fedora-release"
      ETC_ISSUE_KEYWORDS = ['Fedora']

      COMMANDS = COMMANDS.merge(
                   :rpm => '/usr/bin/rpm'
                 )
      def initialize
        @id = :fedora
      end
    end

    class Ubuntu < Distro
      ETC_ISSUE_KEYWORDS = ['ubuntu']

      COMMANDS = {}

      def initialize
        @id = :ubuntu
      end
    end
  end
end
