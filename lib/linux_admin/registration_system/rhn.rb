require 'nokogiri'

module LinuxAdmin
  class Rhn < RegistrationSystem
    SATELLITE5_SERVER_CERT_PATH = "pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm"
    INSTALLED_SERVER_CERT_PATH  = "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT"

    def initialize
      warn("[DEPRECATION] 'LinuxAdmin::Rhn' is deprecated.  Please use 'LinuxAdmin::SubscriptionManager' instead.")
    end

    def registered?(_options = nil)
      id = ""
      if File.exist?(systemid_file)
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

      install_server_certificate(options[:server_url], SATELLITE5_SERVER_CERT_PATH) if options[:server_url]
      certificate_installed = LinuxAdmin::Rpm.list_installed["rhn-org-trusted-ssl-cert"]

      params["--proxy="]          = options[:proxy_address]     if options[:proxy_address]
      params["--proxyUser="]      = options[:proxy_username]    if options[:proxy_username]
      params["--proxyPassword="]  = options[:proxy_password]    if options[:proxy_password]
      params["--serverUrl="]      = options[:server_url]        if options[:server_url]
      params["--systemorgid="]    = options[:org]               if options[:server_url] && options[:org]
      params["--sslCACert="]      = INSTALLED_SERVER_CERT_PATH  if certificate_installed

      Common.run!(cmd, :params => params)
    end

    def enable_channel(repo, options)
      cmd       = "rhn-channel -a"
      params    = user_pwd(options).merge("--channel=" => repo)

      logger.info("#{self.class.name}##{__method__} Enabling channel: #{repo}")
      Common.run!(cmd, :params => params)
    end
    alias_method :subscribe,    :enable_channel
    alias_method :enable_repo,  :enable_channel

    def disable_channel(repo, options)
      cmd       = "rhn-channel -r"
      params    = user_pwd(options).merge("--channel=" => repo)

      Common.run!(cmd, :params => params)
    end
    alias_method :disable_repo, :disable_channel

    def enabled_channels
      cmd = "rhn-channel -l"

      Common.run!(cmd).output.split("\n").compact
    end
    alias_method :enabled_repos, :enabled_channels
    alias_method :subscribed_products, :enabled_channels

    def available_channels(options)
      cmd     = "rhn-channel -L"
      params  = user_pwd(options)

      Common.run!(cmd, :params => params).output.chomp.split("\n").compact
    end

    def all_repos(options)
      available = available_channels_with_status(options)
      merge_enabled_channels_with_status(available)
    end

    private

    def available_channels_with_status(options)
      available_channels(options).collect { |ac| {:repo_id => ac, :enabled => false} }
    end

    def merge_enabled_channels_with_status(available)
      enabled_channels.each_with_object(available) do |enabled, all|
        if repo = all.detect { |i| i[:repo_id] == enabled }
          repo[:enabled] = true
        else
          all.push({:repo_id => enabled, :enabled => true})
        end
      end
    end

    def user_pwd(options)
      raise ArgumentError, "username and password are required" if options[:username].blank? || options[:password].blank?

      {"--user=" => options[:username], "--password=" => options[:password]}
    end

    def systemid_file
      "/etc/sysconfig/rhn/systemid"
    end
  end
end
