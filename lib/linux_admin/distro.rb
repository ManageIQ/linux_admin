# LinuxAdmin Distro Representation
#
# Copyright (C) 2013 Red Hat Inc.
# Licensed under the MIT License

require 'linux_admin/etc_issue'

module LinuxAdmin
  module Distros
    def self.generic
      @generic ||= Distro.new(:generic)
    end

    def self.rhel
      @rhel ||= Distro.new(:rhel, '/etc/redhat-release', ['red hat', 'centos'], LinuxAdmin::Rpm)
    end

    def self.fedora
      @fedora ||= Distro.new(:fedora, "/etc/fedora-release", ['Fedora'], LinuxAdmin::Rpm)
    end

    def self.ubuntu
      @ubuntu ||= Distro.new(:ubuntu, nil, ['ubuntu'], LinuxAdmin::Deb)
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

      def initialize(id, release_file = nil, etc_issue_keywords = [], info_class = nil)
        @id                 = id
        @path               = %w(/sbin /bin /usr/bin /usr/sbin)
        @release_file       = release_file
        @etc_issue_keywords = etc_issue_keywords
        @info_class         = info_class
      end

      def detected?
        detected_by_etc_issue? || detected_by_etc_release?
      end

      def detected_by_etc_issue?
        etc_issue_keywords && etc_issue_keywords.any? { |k| EtcIssue.instance.include?(k) }
      end

      def detected_by_etc_release?
        release_file && File.exist?(release_file)
      end

      def command(name)
        @path.collect { |dir| "#{dir}/#{name}" }.detect { |cmd| File.exist?(cmd) }
      end

      def command?(name)
        !!command(name)
      end

      def info(pkg)
        info_class ? info_class.info(pkg) : nil
      end
    end
  end
end
