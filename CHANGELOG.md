# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [v4.1.0] - 2026-10-27

### Added
- Add Darwin specific network interface and Homebrew support, fixing `ip_route` on macOS [[#257]](https://github.com/ManageIQ/linux_admin/pull/257)

### Changed
- Bump more_core_extensions to 4.5.1 minimum, fixing the require of logger on active_support < 7.0 [[#259]](https://github.com/ManageIQ/linux_admin/pull/259)
- Unlock net-ssh from `v7.2.*` [[#292]](https://github.com/ManageIQ/linux_admin/pull/292)
- Drop support for Ruby 2.6, 2.7, 3.0, and 3.1 [[#293]](https://github.com/ManageIQ/linux_admin/pull/293)

## [v4.0.0] - 2024-08-13

### Added
- Add NetworkInterface#loopback? [[#254]](https://github.com/ManageIQ/linux_admin/pull/254)
- Add NetworkInterface.list [[#249]](https://github.com/ManageIQ/linux_admin/pull/249)

### Changed
- **BREAKING** Use --json for ip command output in NetworkInterface [[#251]](https://github.com/ManageIQ/linux_admin/pull/251)
- Parse config file on NetworkInterface#reload [[#253]](https://github.com/ManageIQ/linux_admin/pull/253)

## [v3.0.0] - 2024-04-30

### Changed
- Bump net-ssh dependency to ~> 7.0 for OpenSSL 3.0 support [[#244]](https://github.com/ManageIQ/linux_admin/pull/244)
- Bump ed25519 upper version limit to 2.0 [[#246]](https://github.com/ManageIQ/linux_admin/pull/246)
- Bump awesome_spawn minimum to 1.6 [[#240]](https://github.com/ManageIQ/linux_admin/pull/240)
- Change redirects to portable format (`> /dev/null 2>&1`) [[#235]](https://github.com/ManageIQ/linux_admin/pull/235)
- Use PATH to find executable commands [[#233]](https://github.com/ManageIQ/linux_admin/pull/233)

### Fixed
- Fix uninitialized constant URI in RegistrationSystem#install_server_certificate [[#247]](https://github.com/ManageIQ/linux_admin/pull/247)

### Removed
- **BREAKING** Drop support for Ruby < 2.6 [[#244]](https://github.com/ManageIQ/linux_admin/pull/244)

## [v2.0.2] - 2020-07-09

### Changed
- Bump more_core_extensions dependency to ~> 4.0 [[#221]](https://github.com/ManageIQ/linux_admin/pull/221)

## [v2.0.1] - 2020-05-29

### Fixed
- Include default pool in LinuxAdmin::Chrony#clear_servers [[#217]](https://github.com/ManageIQ/linux_admin/pull/217)

## [v2.0.0] - 2019-12-12

### Added
- Add `:now` option to `Service#enable` to enable and start a service in one step [[#213]](https://github.com/ManageIQ/linux_admin/pull/213)
- Add model information to `LinuxAdmin::Disk` [[#214]](https://github.com/ManageIQ/linux_admin/pull/214)
- Add `respond_to_missing?` to `RegistrationSystem` [[#212]](https://github.com/ManageIQ/linux_admin/pull/212)

### Changed
- Update SCAP XML element search for compatibility with scap-security-guide 0.1.46+ [[#216]](https://github.com/ManageIQ/linux_admin/pull/216)
- Exclude non-disk devices from `LinuxAdmin::Disk.local` [[#214]](https://github.com/ManageIQ/linux_admin/pull/214)

### Removed
- **BREAKING** Drop `LinuxAdmin::RegistrationSystem::Rhn` [[#210]](https://github.com/ManageIQ/linux_admin/pull/210)
- **BREAKING** Remove deprecated `LinuxAdmin.run!` in favor of `AwesomeSpawn` [[#209]](https://github.com/ManageIQ/linux_admin/pull/209)

## [v1.2.4] - 2019-07-08

### Added
- Implement `FSTab#maximum_column_lengths` for API compatibility [[#208]](https://github.com/ManageIQ/linux_admin/pull/208)

### Fixed
- Fix alignment and whitespace formatting when writing `/etc/fstab` [[#208]](https://github.com/ManageIQ/linux_admin/pull/208)

## [v1.2.3] - 2019-05-14

### Added
- Support NVMe device partition naming [[#205]](https://github.com/ManageIQ/linux_admin/pull/205)

### Fixed
- Support `kB` unit when parsing `parted` output [[#205]](https://github.com/ManageIQ/linux_admin/pull/205)

### Security
- Upgrade `nokogiri` dependency to >= 1.10.3 for CVE-2019-11068 [[#206]](https://github.com/ManageIQ/linux_admin/pull/206)

## [v1.2.2] - 2018-09-27

### Added
- Use `lsblk` to detect local disks, adding support for NVMe devices [[#203]](https://github.com/ManageIQ/linux_admin/pull/203)

### Security
- Upgrade `nokogiri` dependency to >= 1.8.5 for CVE-2018-14404 [[#201]](https://github.com/ManageIQ/linux_admin/pull/201)

## [v1.2.1] - 2018-02-23

### Added
- Raise `SubscriptionManagerError` on `SubscriptionManager` failures [[#199]](https://github.com/ManageIQ/linux_admin/pull/199)

## [v1.2.0] - 2017-12-06

### Deprecated
- Deprecate `LinuxAdmin::Rhn` [[#198]](https://github.com/ManageIQ/linux_admin/pull/198)

### Fixed
- Pass proxy options to `subscription-manager identity` in `SubscriptionManager.registered?` [[#197]](https://github.com/ManageIQ/linux_admin/pull/197)

## [v1.1.0] - 2017-10-30

### Added
- Allow `Pathname` objects in `Mountable.mount_point_exists?` [[#196]](https://github.com/ManageIQ/linux_admin/pull/196)

### Changed
- Bump `net-ssh` dependency to 4.2 and rename `:paranoid` option to `:verify_host_key` [[#195]](https://github.com/ManageIQ/linux_admin/pull/195)

### Security
- Bump `nokogiri` dependency to resolve security vulnerabilities [[#194]](https://github.com/ManageIQ/linux_admin/pull/194)

## [v1.0.1] - 2018-01-10

### Fixed
- Pass proxy options to `subscription-manager identity` in `SubscriptionManager.registered?` [[#197]](https://github.com/ManageIQ/linux_admin/pull/197)

## [v1.0.0] - 2017-10-03

### Added
- Add `platform` attribute to `Scap` class [[#191]](https://github.com/ManageIQ/linux_admin/pull/191)

### Changed
- Use DataStream files instead of XCCDF files in `Scap` [[#192]](https://github.com/ManageIQ/linux_admin/pull/192)

### Fixed
- Allow `NetworkInterface` instantiation when configuration file does not exist [[#190]](https://github.com/ManageIQ/linux_admin/pull/190)

## [v0.20.2] - 2017-07-18

### Fixed
- Prevent changing `BOOTPROTO` to static when configuring static IPv6 address [[#189]](https://github.com/ManageIQ/linux_admin/pull/189)
- Fix network configuration errors when stopping DHCP on interfaces with no IPv6 DHCP client running [[#188]](https://github.com/ManageIQ/linux_admin/pull/188)

## [v0.20.1] - 2017-04-21

### Deprecated
- Deprecate `LinuxAdmin.run` and `LinuxAdmin.run!` in favor of `AwesomeSpawn` [[#186]](https://github.com/ManageIQ/linux_admin/pull/186)

### Fixed
- Restore `LinuxAdmin.run` and `LinuxAdmin.run!` method delegation to prevent breakage in existing scripts [[#186]](https://github.com/ManageIQ/linux_admin/pull/186)

## [v0.20.0] - 2017-03-24

### Added
- Add IPv6 network configuration methods: `enable_dhcp6`, `apply_static6`, `gateway6=`, `address6=`, and `gateway6` [[#177]](https://github.com/ManageIQ/linux_admin/pull/177) [[#178]](https://github.com/ManageIQ/linux_admin/pull/178) [[#185]](https://github.com/ManageIQ/linux_admin/pull/185)
- Add `prefix` and `prefix6` network prefix-length methods [[#181]](https://github.com/ManageIQ/linux_admin/pull/181)
- Add `SystemdService#show` method to query systemd unit metrics [[#174]](https://github.com/ManageIQ/linux_admin/pull/174)

### Fixed
- Support interfaces on systems with no IPv4 address configured [[#184]](https://github.com/ManageIQ/linux_admin/pull/184)

### Removed
- Drop support for Ruby 2.0 [[#173]](https://github.com/ManageIQ/linux_admin/pull/173)

## [v0.19.0] - 2016-10-31

### Added
- Add `Hosts#update_loopback` to update hostname for IPv4 and IPv6 loopback addresses [[#170]](https://github.com/ManageIQ/linux_admin/pull/170)
- Add `TimeDate.timezones` to list available system timezones [[#169]](https://github.com/ManageIQ/linux_admin/pull/169)
- Add `Mountable.mount_point` to discover mount point by device path [[#168]](https://github.com/ManageIQ/linux_admin/pull/168)

### Fixed
- Restart `chronyd` service after making configuration changes if already running [[#163]](https://github.com/ManageIQ/linux_admin/pull/163)
- Disable password prompts in SSH connections by setting `number_of_password_prompts` to 0 [[#165]](https://github.com/ManageIQ/linux_admin/pull/165)
- Improve error messages when `yum check-update` fails [[#166]](https://github.com/ManageIQ/linux_admin/pull/166)

## [v0.18.0] - 2016-07-25

### Added
- Add `SshAgent` class to manage SSH agent and key forwarding [[#160]](https://github.com/ManageIQ/linux_admin/pull/160)

## [v0.17.0] - 2016-07-08

### Removed
- Drop dependency on `activesupport` [[#161]](https://github.com/ManageIQ/linux_admin/pull/161)
- Drop support for Ruby 1.9.3 [[#161]](https://github.com/ManageIQ/linux_admin/pull/161)

## [v0.16.0] - 2016-02-26

### Added
- Add `status` and `reload` methods to `Service` classes [[#156]](https://github.com/ManageIQ/linux_admin/pull/156)
- Add `iburst` parameter when adding NTP servers in `Chrony` [[#157]](https://github.com/ManageIQ/linux_admin/pull/157)

## [v0.15.0] - 2016-02-11

### Changed
- **BREAKING** Change `LinuxAdmin::Common` from a module mixin to a class [[#148]](https://github.com/ManageIQ/linux_admin/pull/148)
- Bump `more_core_extensions` dependency to 2.0 [[#155]](https://github.com/ManageIQ/linux_admin/pull/155)

## [v0.14.0] - 2016-01-15

### Added
- Add `Hardware#total_cores` for CPU core detection [[#147]](https://github.com/ManageIQ/linux_admin/pull/147)

## [v0.13.0] - 2015-12-04

### Added
- Add `Chrony` class for managing `chronyd` configuration [[#146]](https://github.com/ManageIQ/linux_admin/pull/146)
- Add `Hosts#set_canonical_hostname` to set the canonical hostname in `/etc/hosts` [[#144]](https://github.com/ManageIQ/linux_admin/pull/144)

### Fixed
- Allow `NetworkInterface` instantiation when no network configuration file exists [[#140]](https://github.com/ManageIQ/linux_admin/pull/140)
- Prevent failure when only IPv6 addresses are present in `ip addr show` output [[#141]](https://github.com/ManageIQ/linux_admin/pull/141)
- Ensure trailing newline when updating `/etc/hosts` [[#145]](https://github.com/ManageIQ/linux_admin/pull/145)

## [v0.12.1] - 2015-10-22

### Fixed
- Strip whitespace from hostname output in `Hosts` [[#138]](https://github.com/ManageIQ/linux_admin/pull/138)

## [v0.12.0] - 2015-10-22

### Added
- Add distribution-specific `NetworkInterface` management [[#132]](https://github.com/ManageIQ/linux_admin/pull/132)
- Add `Dns` class for managing `/etc/resolv.conf` nameservers and search domains [[#127]](https://github.com/ManageIQ/linux_admin/pull/127) [[#133]](https://github.com/ManageIQ/linux_admin/pull/133)
- Add `gateway`, `netmask`, and `mac_address` methods to `IpAddress` [[#126]](https://github.com/ManageIQ/linux_admin/pull/126)
- Move binary lookup methods `cmd` and `cmd?` to `Common` [[#131]](https://github.com/ManageIQ/linux_admin/pull/131)

## [v0.11.1] - 2015-09-30

### Added
- Add `TimeDate` class wrapping `timedatectl` [[#122]](https://github.com/ManageIQ/linux_admin/pull/122)
- Add `IpAddress` class for network IP address operations [[#124]](https://github.com/ManageIQ/linux_admin/pull/124)
- Add `Hosts.hostname` and `Hosts.hostname=` methods [[#123]](https://github.com/ManageIQ/linux_admin/pull/123)

## [v0.11.0] - 2015-08-12

### Added
- Add `Scap` class for SCAP security scanning and remediation [[#121]](https://github.com/ManageIQ/linux_admin/pull/121)
- Add `Service` dispatching interface and `SystemdService` class [[#117]](https://github.com/ManageIQ/linux_admin/pull/117) [[#118]](https://github.com/ManageIQ/linux_admin/pull/118) [[#119]](https://github.com/ManageIQ/linux_admin/pull/119)

### Fixed
- Parse byte size directly from `fdisk` output in `Disk#size` to prevent SI/binary unit mismatch [[#116]](https://github.com/ManageIQ/linux_admin/pull/116)

## [v0.10.1] - 2015-05-04

### Added
- Add `NullLogger` and logging for repository and GPG operations [[#114]](https://github.com/ManageIQ/linux_admin/pull/114)

## [v0.10.0] - 2015-02-20

### Changed
- **BREAKING** Change `LinuxAdmin` from class to module [[#112]](https://github.com/ManageIQ/linux_admin/pull/112)
- Loosen dependency on `inifile` [[#113]](https://github.com/ManageIQ/linux_admin/pull/113)

## [v0.9.4] - 2014-12-16

### Added
- Allow specifying `:environment` when registering with `SubscriptionManager` [[#110]](https://github.com/ManageIQ/linux_admin/pull/110)

## [v0.9.3] - 2014-12-03

### Fixed
- Avoid passing `--serverurl` in `SubscriptionManager` commands when server RPM is installed [[#109]](https://github.com/ManageIQ/linux_admin/pull/109)

## [v0.9.2] - 2014-11-26

### Fixed
- Ensure `Yum.update` raises an error on argument issues even if exit code is 0 [[#106]](https://github.com/ManageIQ/linux_admin/pull/106)
- Update Satellite 6 certificate RPM filename [[#107]](https://github.com/ManageIQ/linux_admin/pull/107)

## [v0.9.1] - 2014-07-10

### Fixed
- Restore `Package` abstract class to fix `Rpm` command execution [[#104]](https://github.com/ManageIQ/linux_admin/pull/104)

## [v0.9.0] - 2014-07-10

### Changed
- Use `PATH` to discover executable commands instead of hardcoded paths [[#96]](https://github.com/ManageIQ/linux_admin/pull/96)
- Bump `awesome_spawn` dependency to 1.2 [[#101]](https://github.com/ManageIQ/linux_admin/pull/101)

### Fixed
- Fix `Disk.local` to detect Xen `/dev/xvda` disk devices [[#102]](https://github.com/ManageIQ/linux_admin/pull/102)
- Fix `Disk#create_partition` failure with `parted` [[#102]](https://github.com/ManageIQ/linux_admin/pull/102)

## [v0.8.1] - 2014-03-21

### Added
- Add `EtcIssue` helper class for `/etc/issue` [[#85]](https://github.com/ManageIQ/linux_admin/pull/85)

### Fixed
- Support case variations in distribution detection (e.g. CentOS) [[#93]](https://github.com/ManageIQ/linux_admin/pull/93)
- Distinguish between RHEL and Fedora distributions in package handling [[#85]](https://github.com/ManageIQ/linux_admin/pull/85)

## [v0.8.0] - 2014-02-12

### Changed
- **BREAKING** Extract command execution into `awesome_spawn` gem dependency [[#86]](https://github.com/ManageIQ/linux_admin/pull/86)
- Loosen `more_core_extensions` dependency [[#91]](https://github.com/ManageIQ/linux_admin/pull/91)

## [v0.7.0] - 2014-02-03

### Added
- Add repository and channel management methods to `SubscriptionManager` and `Rhn` (`all_repos`, `enabled_repos`, `enable_repo`, `disable_repo`, `available_channels`, `disable_channel`) [[#88]](https://github.com/ManageIQ/linux_admin/pull/88)

## [v0.6.0] - 2014-01-27

### Added
- Add `Rpm.import_key` to import GPG keys [[#87]](https://github.com/ManageIQ/linux_admin/pull/87)

## [v0.5.7] - 2013-12-11

### Changed
- Loosen `active_support` dependency [[#84]](https://github.com/ManageIQ/linux_admin/pull/84)

## [v0.5.6] - 2013-12-05

### Fixed
- Automatically configure `sslCACert` in `Rhn` when certificate RPM is installed [[#83]](https://github.com/ManageIQ/linux_admin/pull/83)

## [v0.5.5] - 2013-12-05

### Added
- Add SSL certificate configuration option when registering to RHN [[#82]](https://github.com/ManageIQ/linux_admin/pull/82)
- Preserve comments and format whitespace in `FSTab` [[#61]](https://github.com/ManageIQ/linux_admin/pull/61)

### Fixed
- Raise `MountError` if a mount point is already in use [[#62]](https://github.com/ManageIQ/linux_admin/pull/62)

## [v0.5.4] - 2013-11-15

### Fixed
- Support `Pathname` object for logical volume name in `LogicalVolume` [[#81]](https://github.com/ManageIQ/linux_admin/pull/81)

## [v0.5.3] - 2013-11-14

### Fixed
- Install server certificate before checking organizations during registration [[#80]](https://github.com/ManageIQ/linux_admin/pull/80)

## [v0.5.2] - 2013-11-13

### Added
- Add `Yum.repo_list` to list configured Yum repositories [[#73]](https://github.com/ManageIQ/linux_admin/pull/73)
- Add package information lookup for RPM and Debian packages [[#74]](https://github.com/ManageIQ/linux_admin/pull/74)
- Add `#install_server_certificate` method to `Rhn` and `SubscriptionManager` [[#79]](https://github.com/ManageIQ/linux_admin/pull/79)
- Add Satellite 5 organization support to `Rhn` registration [[#75]](https://github.com/ManageIQ/linux_admin/pull/75)
- Add `command_line` reader to `CommandResult` [[#78]](https://github.com/ManageIQ/linux_admin/pull/78)
- Accept `path` parameter when initializing `LogicalVolume` [[#64]](https://github.com/ManageIQ/linux_admin/pull/64)

### Fixed
- Require `pathname` in `LogicalVolume` to prevent `NameError` [[#77]](https://github.com/ManageIQ/linux_admin/pull/77)

## [v0.5.1] - 2013-10-10

### Changed
- Update standalone command execution for `repoquery`, `repotrack`, and `createrepo` [[#72]](https://github.com/ManageIQ/linux_admin/pull/72)

## [v0.5.0] - 2013-10-09

### Added
- Add `LinuxAdmin::Rpm.upgrade` [[#70]](https://github.com/ManageIQ/linux_admin/pull/70)

## [v0.4.1] - 2013-10-03

### Fixed
- Check RHN registration first to avoid false positive in `SubscriptionManager.registered?` [[#68]](https://github.com/ManageIQ/linux_admin/pull/68)
- Fix command binary paths for RHEL 6 [[#67]](https://github.com/ManageIQ/linux_admin/pull/67)

## [v0.4.0] - 2013-10-02

### Added
- Add `Hosts` class for managing `/etc/hosts` entries [[#65]](https://github.com/ManageIQ/linux_admin/pull/65)
- Add `Yum.create_repo_file` to generate repository configuration files [[#63]](https://github.com/ManageIQ/linux_admin/pull/63)

### Fixed
- Fix date parsing errors with empty date fields in `SubscriptionManager#subscribed_products` [[#66]](https://github.com/ManageIQ/linux_admin/pull/66)

## [v0.3.0] - 2013-09-19

### Fixed
- Fix registration and subscription handling [[#60]](https://github.com/ManageIQ/linux_admin/pull/60)

## [v0.2.3] - 2013-09-19

### Added
- Add `#subscribed_products` and `#subscribed?` methods, and auto-attach to `#subscribe` [[#59]](https://github.com/ManageIQ/linux_admin/pull/59)
- Support percentage of free space in `Disk#create_partition` [[#52]](https://github.com/ManageIQ/linux_admin/pull/52)

## [v0.2.2] - 2013-09-06

### Added
- Support `Pathname` objects as command arguments and parameters [[#43]](https://github.com/ManageIQ/linux_admin/pull/43)
- Support percentage of free extents in `LogicalVolume#create` [[#49]](https://github.com/ManageIQ/linux_admin/pull/49)
- Raise `NoSuchFileError` when a file does not exist, sanitizing parameters from error messages [[#46]](https://github.com/ManageIQ/linux_admin/pull/46)

### Fixed
- Ignore whitespace-only lines when parsing `/etc/fstab` [[#51]](https://github.com/ManageIQ/linux_admin/pull/51)
- Strip leading whitespace when parsing `pvdisplay` and LVM tool output [[#45]](https://github.com/ManageIQ/linux_admin/pull/45)
- Disable interactive prompts in `parted` by passing `--script` [[#42]](https://github.com/ManageIQ/linux_admin/pull/42)
- Use `chkconfig` for service management on SysV systems [[#50]](https://github.com/ManageIQ/linux_admin/pull/50)

## [v0.2.1] - 2013-08-22

### Fixed
- Create partition table automatically if missing before creating a partition [[#36]](https://github.com/ManageIQ/linux_admin/pull/36)
- Convert numeric and non-string parameters to strings before shell escaping [[#35]](https://github.com/ManageIQ/linux_admin/pull/35)

## [v0.2.0] - 2013-08-16

### Added
- Add `CommandResult` return object for `LinuxAdmin.run` and add `LinuxAdmin.run!` [[#32]](https://github.com/ManageIQ/linux_admin/pull/32)
- Raise `CredentialError` on invalid registration credentials [[#34]](https://github.com/ManageIQ/linux_admin/pull/34)

### Changed
- **BREAKING** Change `LinuxAdmin.run` interface to return `CommandResult` instead of output/exit status [[#32]](https://github.com/ManageIQ/linux_admin/pull/32)

## [v0.1.3] - 2013-08-15

### Added
- Add `RegistrationSystem` base class for `Rhn` and `SubscriptionManager` [[#33]](https://github.com/ManageIQ/linux_admin/pull/33)
- Add LVM write operations for `PhysicalVolume`, `VolumeGroup`, and `LogicalVolume` [[#16]](https://github.com/ManageIQ/linux_admin/pull/16) [[#25]](https://github.com/ManageIQ/linux_admin/pull/25)
- Add `Disk#create_partition`, `Disk#size`, and `Disk#clear` [[#23]](https://github.com/ManageIQ/linux_admin/pull/23) [[#25]](https://github.com/ManageIQ/linux_admin/pull/25)
- Add `Partition#format_to` [[#17]](https://github.com/ManageIQ/linux_admin/pull/17)
- Add `FSTab#write!` [[#18]](https://github.com/ManageIQ/linux_admin/pull/18)
- Add `SubscriptionManager.organizations` to list available organizations [[#24]](https://github.com/ManageIQ/linux_admin/pull/24)
- Add `:chdir` option support to `Common.run` [[#27]](https://github.com/ManageIQ/linux_admin/pull/27)
- Define standard exception classes [[#30]](https://github.com/ManageIQ/linux_admin/pull/30)

### Changed
- Convert `Rhn` and `SubscriptionManager` methods to instance methods [[#33]](https://github.com/ManageIQ/linux_admin/pull/33)

### Fixed
- Handle non-zero exit status from `parted` when disk label is missing [[#15]](https://github.com/ManageIQ/linux_admin/pull/15)
- Fix Red Hat platform detection [[#13]](https://github.com/ManageIQ/linux_admin/pull/13)

### Removed
- Remove `Common.write` in favor of `File.write` [[#31]](https://github.com/ManageIQ/linux_admin/pull/31)

## [v0.1.2] - 2013-07-11

### Added
- Add `FSTab` module for parsing `/etc/fstab` [[#12]](https://github.com/ManageIQ/linux_admin/pull/12)
- Add `Service#restart` method [[#12]](https://github.com/ManageIQ/linux_admin/pull/12)

## [v0.1.1] - 2013-07-08

### Added
- Add `System`, `Disk`, `Partition`, `LogicalVolume`, `Service`, and `Distros` classes [[#6]](https://github.com/ManageIQ/linux_admin/pull/6)
- Add proxy and Satellite 5 support to `Rhn` and `SubscriptionManager` registration and subscription commands [[#7]](https://github.com/ManageIQ/linux_admin/pull/7)

## [v0.1.0] - 2013-05-16

### Added
- Add `Rpm.list_installed` for querying installed packages [[#4]](https://github.com/ManageIQ/linux_admin/pull/4)
- Add `Yum.version_available`, `Yum.repotrack`, `Yum.createrepo`, and `Yum.repo_settings` [[#4]](https://github.com/ManageIQ/linux_admin/pull/4)
- Allow specifying packages to `Yum.update` [[#4]](https://github.com/ManageIQ/linux_admin/pull/4)
- Add options for Subscription Manager registration [[#4]](https://github.com/ManageIQ/linux_admin/pull/4)
- Add `Common.sanitize` for shell escaping [[#4]](https://github.com/ManageIQ/linux_admin/pull/4)

### Fixed
- Fix command execution hanging when output exceeds 64KB pipe buffer [[#3]](https://github.com/ManageIQ/linux_admin/pull/3)

## [v0.0.1] - 2013-04-29

### Added
- Initial release with support for Red Hat Subscription Manager (`SubscriptionManager`), Red Hat Network (`Rhn`), and Yum package manager (`Yum`)

[Unreleased]: https://github.com/ManageIQ/linux_admin/compare/v4.1.0...HEAD
[v4.1.0]: https://github.com/ManageIQ/linux_admin/compare/v4.0.0...v4.1.0
[v4.0.0]: https://github.com/ManageIQ/linux_admin/compare/v3.0.0...v4.0.0
[v3.0.0]: https://github.com/ManageIQ/linux_admin/compare/v2.0.2...v3.0.0
[v2.0.2]: https://github.com/ManageIQ/linux_admin/compare/v2.0.1...v2.0.2
[v2.0.1]: https://github.com/ManageIQ/linux_admin/compare/v2.0.0...v2.0.1
[v2.0.0]: https://github.com/ManageIQ/linux_admin/compare/v1.2.4...v2.0.0
[v1.2.4]: https://github.com/ManageIQ/linux_admin/compare/v1.2.3...v1.2.4
[v1.2.3]: https://github.com/ManageIQ/linux_admin/compare/v1.2.2...v1.2.3
[v1.2.2]: https://github.com/ManageIQ/linux_admin/compare/v1.2.1...v1.2.2
[v1.2.1]: https://github.com/ManageIQ/linux_admin/compare/v1.2.0...v1.2.1
[v1.2.0]: https://github.com/ManageIQ/linux_admin/compare/v1.1.0...v1.2.0
[v1.1.0]: https://github.com/ManageIQ/linux_admin/compare/v1.0.0...v1.1.0
[v1.0.1]: https://github.com/ManageIQ/linux_admin/compare/v1.0.0...v1.0.1
[v1.0.0]: https://github.com/ManageIQ/linux_admin/compare/v0.20.2...v1.0.0
[v0.20.2]: https://github.com/ManageIQ/linux_admin/compare/v0.20.1...v0.20.2
[v0.20.1]: https://github.com/ManageIQ/linux_admin/compare/v0.20.0...v0.20.1
[v0.20.0]: https://github.com/ManageIQ/linux_admin/compare/v0.19.0...v0.20.0
[v0.19.0]: https://github.com/ManageIQ/linux_admin/compare/v0.18.0...v0.19.0
[v0.18.0]: https://github.com/ManageIQ/linux_admin/compare/v0.17.0...v0.18.0
[v0.17.0]: https://github.com/ManageIQ/linux_admin/compare/v0.16.0...v0.17.0
[v0.16.0]: https://github.com/ManageIQ/linux_admin/compare/v0.15.0...v0.16.0
[v0.15.0]: https://github.com/ManageIQ/linux_admin/compare/v0.14.0...v0.15.0
[v0.14.0]: https://github.com/ManageIQ/linux_admin/compare/v0.13.0...v0.14.0
[v0.13.0]: https://github.com/ManageIQ/linux_admin/compare/v0.12.1...v0.13.0
[v0.12.1]: https://github.com/ManageIQ/linux_admin/compare/v0.12.0...v0.12.1
[v0.12.0]: https://github.com/ManageIQ/linux_admin/compare/v0.11.1...v0.12.0
[v0.11.1]: https://github.com/ManageIQ/linux_admin/compare/v0.11.0...v0.11.1
[v0.11.0]: https://github.com/ManageIQ/linux_admin/compare/v0.10.1...v0.11.0
[v0.10.1]: https://github.com/ManageIQ/linux_admin/compare/v0.10.0...v0.10.1
[v0.10.0]: https://github.com/ManageIQ/linux_admin/compare/v0.9.4...v0.10.0
[v0.9.4]: https://github.com/ManageIQ/linux_admin/compare/v0.9.3...v0.9.4
[v0.9.3]: https://github.com/ManageIQ/linux_admin/compare/v0.9.2...v0.9.3
[v0.9.2]: https://github.com/ManageIQ/linux_admin/compare/v0.9.1...v0.9.2
[v0.9.1]: https://github.com/ManageIQ/linux_admin/compare/v0.9.0...v0.9.1
[v0.9.0]: https://github.com/ManageIQ/linux_admin/compare/v0.8.1...v0.9.0
[v0.8.1]: https://github.com/ManageIQ/linux_admin/compare/v0.8.0...v0.8.1
[v0.8.0]: https://github.com/ManageIQ/linux_admin/compare/v0.7.0...v0.8.0
[v0.7.0]: https://github.com/ManageIQ/linux_admin/compare/v0.6.0...v0.7.0
[v0.6.0]: https://github.com/ManageIQ/linux_admin/compare/v0.5.7...v0.6.0
[v0.5.7]: https://github.com/ManageIQ/linux_admin/compare/v0.5.6...v0.5.7
[v0.5.6]: https://github.com/ManageIQ/linux_admin/compare/v0.5.5...v0.5.6
[v0.5.5]: https://github.com/ManageIQ/linux_admin/compare/v0.5.4...v0.5.5
[v0.5.4]: https://github.com/ManageIQ/linux_admin/compare/v0.5.3...v0.5.4
[v0.5.3]: https://github.com/ManageIQ/linux_admin/compare/v0.5.2...v0.5.3
[v0.5.2]: https://github.com/ManageIQ/linux_admin/compare/v0.5.1...v0.5.2
[v0.5.1]: https://github.com/ManageIQ/linux_admin/compare/v0.5.0...v0.5.1
[v0.5.0]: https://github.com/ManageIQ/linux_admin/compare/v0.4.1...v0.5.0
[v0.4.1]: https://github.com/ManageIQ/linux_admin/compare/v0.4.0...v0.4.1
[v0.4.0]: https://github.com/ManageIQ/linux_admin/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/ManageIQ/linux_admin/compare/v0.2.3...v0.3.0
[v0.2.3]: https://github.com/ManageIQ/linux_admin/compare/v0.2.2...v0.2.3
[v0.2.2]: https://github.com/ManageIQ/linux_admin/compare/v0.2.1...v0.2.2
[v0.2.1]: https://github.com/ManageIQ/linux_admin/compare/v0.2.0...v0.2.1
[v0.2.0]: https://github.com/ManageIQ/linux_admin/compare/v0.1.3...v0.2.0
[v0.1.3]: https://github.com/ManageIQ/linux_admin/compare/v0.1.2...v0.1.3
[v0.1.2]: https://github.com/ManageIQ/linux_admin/compare/v0.1.1...v0.1.2
[v0.1.1]: https://github.com/ManageIQ/linux_admin/compare/v0.1.0...v0.1.1
[v0.1.0]: https://github.com/ManageIQ/linux_admin/compare/v0.0.1...v0.1.0
[v0.0.1]: https://github.com/ManageIQ/linux_admin/tree/v0.0.1
