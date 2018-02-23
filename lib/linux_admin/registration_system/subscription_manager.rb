require 'date'

module LinuxAdmin
  class SubscriptionManager < RegistrationSystem
    def run!(cmd, options = {})
      Common.run!(cmd, options)
    rescue AwesomeSpawn::CommandResultError => err
      raise CredentialError.new(err.result) if err.result.error.downcase.include?("invalid username or password")
      raise SubscriptionManagerError.new(err.message, err.result)
    end

    SATELLITE6_SERVER_CERT_PATH = "pub/katello-ca-consumer-latest.noarch.rpm"

    def validate_credentials(options)
      !!organizations(options)
    end

    def registered?(options = nil)
      args = ["subscription-manager identity"]
      args << {:params => proxy_params(options)} if options
      Common.run(*args).exit_status.zero?
    end

    def refresh
      run!("subscription-manager refresh")
    end

    def organizations(options)
      raise ArgumentError, "username and password are required" unless options[:username] && options[:password]

      install_server_certificate(options[:server_url], SATELLITE6_SERVER_CERT_PATH) if options[:server_url]

      cmd = "subscription-manager orgs"

      params = {"--username=" => options[:username], "--password=" => options[:password]}
      params.merge!(proxy_params(options))

      result = run!(cmd, :params => params)
      parse_output(result.output).each_with_object({}) { |i, h| h[i[:name]] = i }
    end

    def register(options)
      raise ArgumentError, "username and password are required" unless options[:username] && options[:password]

      install_server_certificate(options[:server_url], SATELLITE6_SERVER_CERT_PATH) if options[:server_url]

      cmd = "subscription-manager register"

      params = {"--username=" => options[:username], "--password=" => options[:password]}
      params.merge!(proxy_params(options))
      params["--environment="] = options[:environment] if options[:environment]
      params["--org="]         = options[:org]         if options[:server_url] && options[:org]

      run!(cmd, :params => params)
    end

    def subscribe(options)
      cmd    = "subscription-manager attach"
      params = proxy_params(options)

      if options[:pools].blank?
        params.merge!({"--auto" => nil})
      else
        pools  = options[:pools].collect {|pool| ["--pool", pool]}
        params = params.to_a + pools
      end

      run!(cmd, :params => params)
    end

    def subscribed_products
      cmd     = "subscription-manager list --installed"
      output  = run!(cmd).output

      parse_output(output).select {|p| p[:status].downcase == "subscribed"}.collect {|p| p[:product_id]}
    end

    def available_subscriptions
      cmd     = "subscription-manager list --all --available"
      output  = run!(cmd).output
      parse_output(output).each_with_object({}) { |i, h| h[i[:pool_id]] = i }
    end

    def enable_repo(repo, options = nil)
      cmd     = "subscription-manager repos"
      params  = {"--enable=" => repo}

      logger.info("#{self.class.name}##{__method__} Enabling repository: #{repo}")
      run!(cmd, :params => params)
    end

    def disable_repo(repo, options = nil)
      cmd     = "subscription-manager repos"
      params  = {"--disable=" => repo}

      run!(cmd, :params => params)
    end

    def all_repos(options = nil)
      cmd     = "subscription-manager repos"
      output  = run!(cmd).output

      parse_output(output)
    end

    def enabled_repos
      all_repos.select { |i| i[:enabled] }.collect { |r| r[:repo_id] }
    end

    private

    def parse_output(output)
      # Strip the 3 line header off the top
      content = output.split("\n")[3..-1].join("\n")
      parse_content(content)
    end

    def parse_content(content)
      # Break into content groupings by "\n\n" then process each grouping
      content.split("\n\n").each_with_object([]) do |group, group_array|
        group = group.split("\n").each_with_object({}) do |line, hash|
          next if line.blank?
          key, value = line.split(":", 2)
          hash[key.strip.downcase.tr(" -", "_").to_sym] = value.strip unless value.blank?
        end
        group_array.push(format_values(group))
      end
    end

    def format_values(content_group)
      content_group[:enabled] = content_group[:enabled].to_i == 1  if content_group[:enabled]
      content_group[:ends]    = Date.strptime(content_group[:ends], "%m/%d/%Y")   if content_group[:ends]
      content_group[:starts]  = Date.strptime(content_group[:starts], "%m/%d/%Y") if content_group[:starts]
      content_group
    end

    def proxy_params(options)
      config = {}
      config["--proxy="]          = options[:proxy_address]   if options[:proxy_address]
      config["--proxyuser="]      = options[:proxy_username]  if options[:proxy_username]
      config["--proxypassword="]  = options[:proxy_password]  if options[:proxy_password]
      config
    end
  end
end
