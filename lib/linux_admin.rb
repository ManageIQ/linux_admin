require 'linux_admin/common'
require 'linux_admin/rhn'
require 'linux_admin/subscription_manager'
require 'linux_admin/version'
require 'linux_admin/yum'

module LinuxAdmin
  def self.registered?
    !!self.registration_type
  end

  def self.registration_type
    if SubscriptionManager.registered?
      SubscriptionManager
    elsif Rhn.registered?
      Rhn
    else
      nil
    end
  end
end
