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
- Add network interface loopback [[#254]](https://github.com/ManageIQ/linux_admin/pull/254)
- Add LinuxAdmin::NetworkInterface.list [[#249]](https://github.com/ManageIQ/linux_admin/pull/249)

### Changed
- **BREAKING** Use --json for ip command output [[#251]](https://github.com/ManageIQ/linux_admin/pull/251)
- Parse config file on NetworkInterface#reload [[#253]](https://github.com/ManageIQ/linux_admin/pull/253)

## [v3.0.0] - 2024-04-30

### Changed
- **BREAKING** Bump required_ruby_version to 2.6 & Bump net-ssh for OpenSSL 3.0 support [[#244]](https://github.com/ManageIQ/linux_admin/pull/244)
- Bump ed25519 upper version limit to 2.0 [[#246]](https://github.com/ManageIQ/linux_admin/pull/246)
- Bump awesome_spawn minimum to 1.6 [[#240]](https://github.com/ManageIQ/linux_admin/pull/240)
- Change redirects to be portable [[#235]](https://github.com/ManageIQ/linux_admin/pull/235)
- use PATH to find executable commands [[#233]](https://github.com/ManageIQ/linux_admin/pull/233)

## [v2.0.2] - 2020-07-09

### Fixed
- Update dependency on more_core_extensions [[#221]](https://github.com/ManageIQ/linux_admin/pull/221)

## [v2.0.1] - 2020-05-29

### Fixed
- LinuxAdmin::Chrony#clear_servers should include the default pool [[#217]](https://github.com/ManageIQ/linux_admin/pull/217)

[Unreleased]: https://github.com/ManageIQ/linux_admin/compare/v4.1.0...HEAD
[v4.1.0]: https://github.com/ManageIQ/linux_admin/compare/v4.0.0...v4.1.0
[v4.0.0]: https://github.com/ManageIQ/linux_admin/compare/v3.0.0...v4.0.0
[v3.0.0]: https://github.com/ManageIQ/linux_admin/compare/v2.0.2...v3.0.0
[v2.0.2]: https://github.com/ManageIQ/linux_admin/compare/v2.0.1...v2.0.2
[v2.0.1]: https://github.com/ManageIQ/linux_admin/compare/v2.0.0...v2.0.1
