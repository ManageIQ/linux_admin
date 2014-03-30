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
      attr_accessor :release_file, :etc_issue_keywords, :info_class

      def initialize(release_file = nil, etc_issue_keywords = [], info_class = nil)
        @path               = %w(/sbin /bin /usr/bin /usr/sbin)
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
        etc_issue_keywords && etc_issue_keywords.any? { |k| EtcIssue.instance.include?(k) }
      end

      def detected_by_etc_release?
        release_file && File.exists?(release_file)
      end

      def command(name)
        @path.collect { |dir| "#{dir}/#{name}" }.detect { |cmd| File.exists?(cmd) }
      end

      def info(pkg)
        info_class ? info_class.info(pkg) : nil
      end
    end

    class Generic < Distro
      def initialize
        super()
      end
    end

    class RedHat < Distro
      def initialize(release_file, etc_issue_keywords)
        super(release_file, etc_issue_keywords, LinuxAdmin::Rpm)
      end
    end

    class RHEL < RedHat
      def initialize
        super('/etc/redhat-release', ['red hat','centos'])
      end

      # def detected?
      #   super || File.exists?("/etc/redhat-release")
      # end
    end

    class Fedora < RedHat
      def initialize
        super("/etc/fedora-release", ['Fedora'])
      end
    end

    class Ubuntu < Distro
      def initialize
        super(nil, ['ubuntu'], LinuxAdmin::Deb)
      end
    end
  end
end
