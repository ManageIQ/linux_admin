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

    def self.mac
      @mac ||= Distro.new(:mac, "/etc/mach_init.d")
    end

    def self.all
      @distros ||= [rhel, fedora, ubuntu, mac, generic]
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

      def info(pkg)
        info_class ? info_class.info(pkg) : nil
      end
    end
  end
end
