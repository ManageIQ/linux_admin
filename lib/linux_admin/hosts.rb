module LinuxAdmin
  class Hosts
    include Common

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
      File.write(@filename, @raw_lines.join("\n"))
    end

    def update_entry(address, hostname, comment = nil)
      # Delete entries for this hostname first
      @parsed_file.each {|i| i[:hosts].to_a.delete(hostname)}

      # Add entry
      line_number = @parsed_file.find_path(address).first

      if line_number.blank?
        @parsed_file.push({:address => address, :hosts => [hostname], :comment => comment})
      else
        new_hosts = @parsed_file.fetch_path(line_number, :hosts).to_a.push(hostname)
        @parsed_file.store_path(line_number, :hosts, new_hosts)
        @parsed_file.store_path(line_number, :comment, comment) if comment
      end
    end

    # Updates the IP address associated with the entry specified by the hostname
    # or inserts a new row in the file if there is no entry for that name
    #
    # @param hostname [String] the hostname used to find the record to update
    # @param ip [String] the new address to use for the record
    def update_ip_for_hostname(host, ip)
      line_num = @parsed_file.find_path(host).first
      if line_num
        @parsed_file[line_num][:address] = ip
      else
        update_entry(ip, host)
      end
    end

    def hostname=(name)
      if cmd?("hostnamectl")
        run!(cmd('hostnamectl'), :params => ['set-hostname', name])
      else
        File.write("/etc/hostname", name)
        run!(cmd('hostname'), :params => {:file => "/etc/hostname"})
      end
    end

    def hostname
      result = run(cmd("hostname"))
      result.success? ? result.output : nil
    end

  private
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
