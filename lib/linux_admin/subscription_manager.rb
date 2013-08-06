require 'date'

class LinuxAdmin
  class SubscriptionManager < LinuxAdmin
    def self.registered?
      run("subscription-manager identity", :return_exitstatus => true) == 0
    end

    def self.refresh
      run("subscription-manager refresh")
    end

    def self.register(options)
      raise ArgumentError, "username and password are required" unless options[:username] && options[:password]
      cmd = "subscription-manager register"

      params = {"--username=" => options[:username], "--password=" => options[:password]}
      params.merge!(proxy_params(options))
      params["--org="]        = options[:org]         if options[:server_url] && options[:org]
      params["--serverurl="]  = options[:server_url]  if options[:server_url]

      run(cmd, :params => params)
    end

    def self.subscribe(options)
      cmd    = "subscription-manager attach"
      pools  = options[:pools].collect {|pool| ["--pool", pool]}
      params = proxy_params(options).to_a + pools

      run(cmd, :params => params)
    end

    def self.available_subscriptions
      cmd = "subscription-manager list --all --available"
      parse_output(run(cmd, :return_output => true))
    end

    private


    def self.parse_output(output)
      # Strip the 3 line header off the top
      content = output.split("\n")[3..-1].join("\n")

      # Break into groupings by "\n\n" then process each grouping
      content.split("\n\n").each_with_object({}) do |group, group_hash|
        hash = {}
        group.each_line do |line|
          key, value = line.split(":", 2)
          hash[key.strip.downcase.tr(" -", "_").to_sym] = value.strip
        end
        hash[:ends] = Date.strptime(hash[:ends], "%m/%d/%Y")

        group_hash[hash[:pool_id]] = hash
      end
    end

    def self.proxy_params(options)
      config = {}
      config["--proxy="]          = options[:proxy_address]   if options[:proxy_address]
      config["--proxyuser="]      = options[:proxy_username]  if options[:proxy_username]
      config["--proxypassword="]  = options[:proxy_password]  if options[:proxy_password]
      config
    end
  end
end