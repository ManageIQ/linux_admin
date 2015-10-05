module LinuxAdmin
  class Dns
    attr_accessor :filename
    attr_accessor :nameservers
    attr_accessor :search_order

    def initialize(filename = "/etc/resolv.conf")
      @filename = filename
      reload
    end

    def reload
      @search_order = []
      @nameservers  = []

      File.read(@filename).split("\n").each do |line|
        if line =~ /^search .*/
          @search_order += line.split(/^search\s+/)[1].split
        elsif line =~ /^nameserver .*/
          @nameservers.push(line.split[1])
        end
      end
    end

    def save
      contents = "search #{@search_order.join(" ")}\n"
      @nameservers.each { |ns| contents += "nameserver #{ns}\n" }
      File.write(@filename, contents)
    end
  end
end
