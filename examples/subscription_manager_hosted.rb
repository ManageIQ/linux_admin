$:.push("../lib")
require 'linux_admin'

username = "MyUsername"
password = "MyPassword"


reg_status = LinuxAdmin.registered?
puts "Registration Status: #{reg_status.to_s}"

unless reg_status
  puts "Registering to Subscription Manager..."
  LinuxAdmin::SubscriptionManager.register(:username => username, :password => password)
end

reg_type = LinuxAdmin.registration_type
puts "Registration System: #{reg_type}"

puts "Subscribing to channels..."
reg_type.subscribe(reg_type.available_subscriptions.keys.first)
puts "Checking for updates..."
if LinuxAdmin::Yum.updates_available?
  puts "Updates Available \n Updating..."
  puts "Updates Applied" if LinuxAdmin::Yum.update
end
