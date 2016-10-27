module LinuxAdmin
  class Hosts
    attr_accessor :filename
    attr_accessor :raw_lines
    attr_accessor :parsed_file

    def initialize(filename = "/etc/hosts")
      @filename = filename
      self.reload
    end

    def reload
      @raw_lines = File.read(@filename).split("\n")
      parse_file
    end

    def save
      cleanup_empty
      @raw_lines = assemble_lines
      File.write(@filename, @raw_lines.join("\n") + "\n")
    end

    def add_alias(address, hostname, comment = nil)
      add_name(address, hostname, false, comment)
    end

    alias_method :update_entry, :add_alias

    def set_loopback_hostname(hostname, comment = nil)
      ["::1", "127.0.0.1"].each { |address| add_name(address, hostname, true, comment, false) }
    end

    def set_canonical_hostname(address, hostname, comment = nil)
      add_name(address, hostname, true, comment)
    end

    def hostname=(name)
      if Common.cmd?("hostnamectl")
        Common.run!(Common.cmd('hostnamectl'), :params => ['set-hostname', name])
      else
        File.write("/etc/hostname", name)
        Common.run!(Common.cmd('hostname'), :params => {:file => "/etc/hostname"})
      end
    end

    def hostname
      result = Common.run(Common.cmd("hostname"))
      result.success? ? result.output.strip : nil
    end

    private

    def add_name(address, hostname, fqdn, comment, remove_existing = true)
      # Delete entries for this hostname first
      @parsed_file.each { |i| i[:hosts].to_a.delete(hostname) } if remove_existing

      # Add entry
      line_number = @parsed_file.find_path(address).first

      if line_number.blank?
        @parsed_file.push(:address => address, :hosts => [hostname], :comment => comment)
      else
        if fqdn
          new_hosts = @parsed_file.fetch_path(line_number, :hosts).to_a.unshift(hostname)
        else
          new_hosts = @parsed_file.fetch_path(line_number, :hosts).to_a.push(hostname)
        end
        @parsed_file.store_path(line_number, :hosts, new_hosts)
        @parsed_file.store_path(line_number, :comment, comment) if comment
      end
    end

    def parse_file
      @parsed_file = []
      @raw_lines.each { |line| @parsed_file.push(parse_line(line.strip)) }
      @parsed_file.delete_blank_paths
    end

    def parse_line(line)
      data, comment   = line.split("#", 2)
      address, hosts  = data.to_s.split(" ", 2)
      hostnames       = hosts.to_s.split(" ")

      { :address => address.to_s, :hosts => hostnames, :comment => comment.to_s.strip, :blank => line.blank?}
    end

    def cleanup_empty
      @parsed_file.each do |h|
        h.delete(:hosts) if h[:address].blank?
        h.delete(:address) if h[:hosts].blank?
      end

      @parsed_file.delete_blank_paths
    end

    def assemble_lines
      @parsed_file.each_with_object([]) { |l, a| a.push(l[:blank] ? "" : build_line(l[:address], l[:hosts], l[:comment])) }
    end

    def build_line(address, hosts, comment)
      line = [address.to_s.ljust(16), hosts.to_a.uniq]
      line.push("##{comment}") if comment
      line.flatten.join(" ").strip
    end
  end
end
