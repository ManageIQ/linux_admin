require 'more_core_extensions/all'
require 'active_support/core_ext'

require 'linux_admin/registration_system'

require 'linux_admin/common'
require 'linux_admin/exceptions'
require 'linux_admin/rpm'
require 'linux_admin/version'
require 'linux_admin/yum'

require 'linux_admin/service'
require 'linux_admin/disk'
require 'linux_admin/partition'
require 'linux_admin/distro'
require 'linux_admin/system'
require 'linux_admin/fstab'
require 'linux_admin/logical_volume'
require 'linux_admin/physical_volume'
require 'linux_admin/volume_group'

class LinuxAdmin
  extend Common
  include Common
end
