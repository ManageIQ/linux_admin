require 'date'

module LinuxAdmin
  module SubscriptionManager
    def self.registered?
      Common.run("subscription-manager identity", :return_exitstatus => true) == 0
    end

    def self.refresh
      Common.run("subscription-manager refresh")
    end

    def self.register(options = {})
      cmd = "subscription-manager register"
      cmd << " --username=#{options[:username]} --password=#{options[:password]}" if options[:username] && options[:password]
      Common.run(cmd)
    end

    def self.subscribe(pool_id)
      Common.run("subscription-manager attach --pool #{pool_id}")
    end

    def self.available_subscriptions
      output = Common.run("subscription-manager list --all --available", :return_output => true)
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