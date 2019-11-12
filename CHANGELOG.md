# Change Log

Notable changes to new releases of Puppet Dashboard.

## [3.0.1] - 2019-11-12

### Fixed

- Fix the cli progressbar by using the ruby-progressbar gem
- Fix an issue with report format 6 where the 'kind' key gets removed
- Update multiple gem dependencies

## [3.0.0] - 2019-07-01

This release includes changes from over 5 years since the 2.0.0-beta2 release.

### Fixed

- Handle delayed_job failures better
- Various enhancements to sorting in various views
- Improvements to error detection in the log
- Partial radiator reload
- Various fixes to various tasks

### Changed

- Updated Rails framework to 5.2.3
- Support for new Ruby versions (2.4, 2.5, 2.6)
- Support for older Ruby versions has been removed as several gem dependencies
  are no longer compatible

### Added

- The old manual from the website is now available as markdown documents in the source tree.
- Support for new Report formats
- PostgreSQL optimizations
- New task to delete a variable on a node
- Node add,show and delete tasks now accept a list of nodes
- Basic support for environments

## Other

- Restructuring to maintain Puppet Dashboard as an open source project
- Added haml-lint, rubocop and coverage reports for code maintenance
