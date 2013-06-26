require 'more_core_extensions/all'
require 'active_support/core_ext'

require 'linux_admin/common'
require 'linux_admin/rhn'
require 'linux_admin/rpm'
require 'linux_admin/subscription_manager'
require 'linux_admin/version'
require 'linux_admin/yum'

require 'linux_admin/service'
require 'linux_admin/disk'
require 'linux_admin/partition'
require 'linux_admin/distro'

class LinuxAdmin
  extend Common
  include Common

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
