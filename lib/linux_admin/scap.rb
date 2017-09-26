require 'nokogiri'

module LinuxAdmin
  class Scap
    PROFILE_ID = "linux-admin-scap"
    SSG_XML_PATH = Pathname.new("/usr/share/xml/scap/ssg/content/")

    attr_reader :platform

    def self.openscap_available?
      require 'openscap'
      true
    rescue LoadError
      false
    end

    def self.ssg_available?(platform = nil)
      xccdf_file(platform) && oval_file(platform)
    end

    def initialize(platform = nil)
      @platform = platform
    end

    def ssg_available?
      self.class.ssg_available?(platform)
    end

    def lockdown(*args)
      raise "OpenSCAP not available" unless self.class.openscap_available?
      raise "SCAP Security Guide not available" unless ssg_available?

      values = args.last.kind_of?(Hash) ? args.pop : {}
      rules = args

      raise "No SCAP rules provided" if rules.empty?

      with_xml_files(rules, values) do |xccdf_file_path|
        lockdown_profile(xccdf_file_path, PROFILE_ID)
      end
    end

    def lockdown_profile(xccdf_file_path, profile_id)
      raise "OpenSCAP not available" unless self.class.openscap_available?

      session = OpenSCAP::Xccdf::Session.new(xccdf_file_path)
      session.load
      session.profile = profile_id
      session.evaluate
      session.remediate
    ensure
      session.destroy if session
    end

    private

    def self.xccdf_file(platform)
      local_ssg_file("xccdf", platform)
    end

    def self.oval_file(platform)
      local_ssg_file("oval", platform)
    end

    def self.local_ssg_file(type, platform)
      platform ||= "*"
      Dir.glob(SSG_XML_PATH.join("ssg-#{platform}-#{type}.xml")).detect { |f| f =~ /ssg-\w+-#{type}.xml/ }
    end

    def tempdir
      @tempdir ||= Pathname.new(Dir.tmpdir)
    end

    def xccdf_file
      @xccdf_file ||= self.class.xccdf_file(platform)
    end

    def oval_file
      @oval_file ||= self.class.oval_file(platform)
    end

    def with_xml_files(rules, values)
      FileUtils.cp(oval_file, tempdir)

      Tempfile.create("scap_xccdf") do |f|
        write_xccdf_xml(f, profile_xml(PROFILE_ID, rules, values))
        f.close
        yield f.path
      end
    ensure
      FileUtils.rm_f(tempdir.join(File.basename(oval_file)))
    end

    def profile_xml(profile_id, rules, values)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.Profile(:id => profile_id) do
          xml.title(profile_id)
          xml.description(profile_id)
          rules.each { |r| xml.select(:idref => r, :selected => "true") }
          values.each { |k, v| xml.send("refine-value", :idref => k, :selector => v) }
        end
      end
      builder.doc.root.to_xml
    end

    def write_xccdf_xml(io, profile_xml)
      File.open(xccdf_file) do |f|
        doc = Nokogiri::XML(f)
        model = doc.at_css("model")
        model.add_next_sibling("\n#{profile_xml}")
        io.write(doc.root.to_xml)
      end
    end
  end
end
