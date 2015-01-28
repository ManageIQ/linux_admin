require 'inifile'

module LinuxAdmin
  class Yum
    class RepoFile < IniFile
      def self.create(filename)
        File.write(filename, "")
        self.new(:filename => filename)
      end
    end
  end
end