require 'nokogiri'

module LinuxAdmin
  class Scap
    PROFILE_ID = "xccdf_org.ssgproject.content_profile_linux-admin-scap".freeze
    SSG_XML_PATH = Pathname.new("/usr/share/xml/scap/ssg/content/")

    attr_reader :platform

    def self.openscap_available?
      require 'openscap'
      true
    rescue LoadError
      false
    end

    def self.ssg_available?(platform)
      ds_file(platform).exist?
    end

    def self.ds_file(platform)
      SSG_XML_PATH.join("ssg-#{platform}-ds.xml")
    end

    def initialize(platform)
      @platform = platform
    end

    def lockdown(*args)
      raise "OpenSCAP not available" unless self.class.openscap_available?
      raise "SCAP Security Guide not available" unless self.class.ssg_available?(platform)

      values = args.last.kind_of?(Hash) ? args.pop : {}
      rules = args

      raise "No SCAP rules provided" if rules.empty?

      with_ds_file(rules, values) do |path|
        lockdown_profile(path, PROFILE_ID)
      end
    end

    def lockdown_profile(ds_path, profile_id)
      raise "OpenSCAP not available" unless self.class.openscap_available?

      session = OpenSCAP::Xccdf::Session.new(ds_path)
      session.load
      session.profile = profile_id
      session.evaluate
      session.remediate
    ensure
      session.destroy if session
    end

    private

    def with_ds_file(rules, values)
      Tempfile.create("scap_ds") do |f|
        write_ds_xml(f, profile_xml(PROFILE_ID, rules, values))
        f.close
        yield f.path
      end
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

    def write_ds_xml(io, profile_xml)
      File.open(self.class.ds_file(platform)) do |f|
        doc = Nokogiri::XML(f)
        model_xml_element(doc).add_next_sibling("\n#{profile_xml}")
        io.write(doc.root.to_xml)
      end
    end

    def model_xml_element(doc)
      doc.xpath("//ns10:model").first
    end
  end
end
