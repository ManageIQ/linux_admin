require 'more_core_extensions/all'
require 'active_support'
require 'active_support/core_ext'

require 'linux_admin/logging'
require 'linux_admin/null_logger'

require 'linux_admin/common'
require 'linux_admin/exceptions'
require 'linux_admin/package'
require 'linux_admin/registration_system'
require 'linux_admin/rpm'
require 'linux_admin/deb'
require 'linux_admin/version'
require 'linux_admin/yum'

require 'linux_admin/service'
require 'linux_admin/mountable'
require 'linux_admin/disk'
require 'linux_admin/hardware'
require 'linux_admin/hosts'
require 'linux_admin/partition'
require 'linux_admin/etc_issue'
require 'linux_admin/distro'
require 'linux_admin/system'
require 'linux_admin/fstab'
require 'linux_admin/volume'
require 'linux_admin/logical_volume'
require 'linux_admin/physical_volume'
require 'linux_admin/volume_group'
require 'linux_admin/scap'
require 'linux_admin/time_date'
require 'linux_admin/ip_address'
require 'linux_admin/dns'
require 'linux_admin/network_interface'
require 'linux_admin/chrony'

module LinuxAdmin
  extend Common

  class << self
    attr_writer :logger
  end

  def self.logger
    @logger ||= NullLogger.new
  end
end
