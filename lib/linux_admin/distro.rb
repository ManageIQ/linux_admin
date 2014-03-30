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
      @distros ||= [rhel, fedora, ubuntu, generic]
    end

    def self.local
      @local ||= begin
        Distros.all.detect(&:detected?) || Distros.generic
      end
    end

    class Distro
      attr_accessor :commands, :release_file, :etc_issue_keywords, :info_class

      def initialize(commands, release_file = nil, etc_issue_keywords = [], info_class = nil)
        @commands           = commands
        @release_file       = release_file
        @etc_issue_keywords = etc_issue_keywords
        @info_class         = info_class
      end

      def id
        @id ||= self.class.name.downcase.to_sym
      end

      def detected?
        detected_by_etc_issue? || detected_by_etc_release?
      end

      def detected_by_etc_issue?
        etc_issue_keywords && etc_issue_keywords.any? { |k| EtcIssue.instance.to_s.include?(k) }
      end

      def detected_by_etc_release?
        release_file && File.exists?(release_file)
      end

      def command(name)
        commands[name]
      end

      def info(pkg)
        info_class ? info_class.info(pkg) : nil
      end
    end

    class Generic < Distro
      def initialize
        super({})
      end
    end

    class RedHat < Distro
      def initialize(extra_commands, release_file, etc_issue_keywords)
        super({
          :service   => '/sbin/service',
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
          :vgcreate  => '/sbin/vgcreate'
          }.merge(extra_commands), release_file, etc_issue_keywords, LinuxAdmin::Rpm)
      end
    end

    class RHEL < RedHat
      def initialize
        super({:rpm => '/bin/rpm'}, '/etc/redhat-release', ['red hat', 'Red Hat', 'centos', 'CentOS'])
      end

      # def detected?
      #   super || File.exists?("/etc/redhat-release")
      # end
    end

    class Fedora < RedHat
      def initialize
        super({:rpm => '/usr/bin/rpm'}, "/etc/fedora-release", ['Fedora'])
      end
    end

    class Ubuntu < Distro
      def initialize
        super({}, nil, ['ubuntu'], LinuxAdmin::Deb)
      end
    end
  end
end
