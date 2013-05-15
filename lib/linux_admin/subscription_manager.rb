require 'date'

class LinuxAdmin
  class SubscriptionManager < LinuxAdmin
    def self.registered?
      run("subscription-manager identity", :return_exitstatus => true) == 0
    end

    def self.refresh
      run("subscription-manager refresh")
    end

    def self.register(options = {})
      raise ArgumentError, "username and password are required" unless options[:username] && options[:password]
      cmd = "subscription-manager register"
      cmd << " --username=#{sanitize(options[:username])} --password=#{sanitize(options[:password])}" if options[:username] && options[:password]
      cmd << " --org=#{sanitize(options[:org])}"                       if options[:org] && options[:server_url]
      cmd << " --proxy=#{sanitize(options[:proxy_address])}"           if options[:proxy_address]
      cmd << " --proxyuser=#{sanitize(options[:proxy_username])}"      if options[:proxy_username]
      cmd << " --proxypassword=#{sanitize(options[:proxy_password])}"  if options[:proxy_password]
      cmd << " --serverurl=#{sanitize(options[:server_url])}"          if options[:server_url]
      run(cmd)
    end

    def self.subscribe(pool_id)
      run(sanitize("subscription-manager attach --pool #{pool_id}"))
    end

    def self.available_subscriptions
      output = run("subscription-manager list --all --available", :return_output => true)
      output.split("\n\n").each_with_object({}) do |subscription, subscriptions_hash|
        hash = {}
        subscription.each_line do |line|
          # Strip the header lines if they exist
          next if (line.start_with?("+---") && line.end_with?("---+\n")) || line.strip == "Available Subscriptions"

          key, value = line.split(":", 2)
          hash[key.strip.downcase.tr(" -", "_").to_sym] = value.strip
        end
        hash[:ends] = Date.strptime(hash[:ends], "%m/%d/%Y")

        subscriptions_hash[hash[:pool_id]] = hash
      end
    end
  end
end