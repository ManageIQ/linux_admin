require 'nokogiri'

class LinuxAdmin
  class Rhn < RegistrationSystem
    def registered?
      id = ""
      if File.exists?(systemid_file)
        xml = Nokogiri.XML(File.read(systemid_file))
        id = xml.xpath('/params/param/value/struct/member[name="system_id"]/value/string').text
      end
      id.length > 0
    end

    def register(options)
      cmd    = "rhnreg_ks"
      params = {}

      if options[:activationkey]
        params["--activationkey="]  = options[:activationkey]
      elsif options[:username] && options[:password]
        params["--username="]       = options[:username]
        params["--password="]       = options[:password]
      else
        raise ArgumentError, "activation key or username and password are required"
      end

      params["--proxy="]          = options[:proxy_address]   if options[:proxy_address]
      params["--proxyUser="]      = options[:proxy_username]  if options[:proxy_username]
      params["--proxyPassword="]  = options[:proxy_password]  if options[:proxy_password]
      params["--serverUrl="]      = options[:server_url]      if options[:server_url]
      params["--systemorgid="]    = options[:org]             if options[:server_url] && options[:org]

      run!(cmd, :params => params)
    end

    def subscribe(options)
      raise ArgumentError, "channels, username and password are required" if options[:channels].blank? || options[:username].blank? || options[:password].blank?
      cmd = "rhn-channel -a"

      channels = options[:channels].collect {|channel| ["--channel=", channel]}

      params                = {}
      params["--user="]     = options[:username]
      params["--password="] = options[:password]
      params                = params.to_a + channels

      run!(cmd, :params => params)
    end

    def subscribed_products
      cmd = "rhn-channel -l"
      run!(cmd).output.split("\n").compact
    end

    private

    def systemid_file
      "/etc/sysconfig/rhn/systemid"
    end
  end
end