Puppet Dashboard Release Notes
==============================

v1.1.1
------
* Use absolute paths for cert/private key
* Document the `rake reports:schematize` upgrade process
* #6980 - Updated DEB packaging for 1.1.0
* #6980 - Updated RPM spec file for Puppet Dashboard
* maint: Clean sample reports before generating new ones
* (#6862) Add a default subject for the mail_patches rake task
* require 'yaml' should be lowercase, works on macs for some reason
* (#6532) Add NUM_REPORTS to reports:samples:generate rake task
* (#6533) Add rake task to generate unresponsive nodes
* (#6532) Add options to sample generator rake task
* (#6532) Add combination rake task for generating & importing samples
* (#6532) Change report generator to a rake task
* Print error message when rake:import fails
* (#6531) Folded into one file & renamed
* (#6531) Add ability to generate events
* Branch with report generation utility
* (#6736) Add require 'thread' to rakefile
* Make sure config/installed_plugins is present before db:migrate
* (#6684) Sanitize plugin migration names

v1.1.0
------

* Updated CHANGELOG for 1.1.0rc3
* Updated VERSION for 1.1.0rc3
* Updated CHANGELOG for 1.1.0rc2
* (#6835) Handle malformed facts from Puppet 2.6.7 & storedconfigs
* Update CHANGELOG and version for 1.1.0rc1
* maint: Add missing CHANGELOG entries for 1.0.3 to 1.0.4
* (#6736) Provide Mutex, avoid an error.
* maint: Move inventory section lower on the node page
* (#4403) Do timezone arithmetic outside of the DB in the Status model
* Remove dead code from Status model
* Validate the user supplied daily_run_history_length
* (#6656) Inventory service is no longer experimental.
* (#6601) Inventory search uses the new inventory URL
* (#5711) Change license from GPLv3 to GPLv2
* (#5234) Source of silk icons attributed, per author's license
* Maint: Moved logic for identifying inspect reports into a callback.
* Maint: removed bogus comments from _report.html.haml
* Maint: Moved elements of the report "show" view into callbacks.
* Maint: Moved elements of the node "show" view into callbacks.
* Maint: Forbid uninstalled plugins from adding themselves to hooks.
* Maint: Add plug-in install and uninstall rake tasks
* Maint: removed db/schema.rb
* Maint: Removed some private methods in the report model that are part of baseline functionality.
* Maint: remove code that belongs in the "baseline" module.
* maint: Added log dir to version control
* Maint: Add puppet plugins to .gitignore
* Bug fix: renamed each_hook and find_first_hook to *_callback
* Remove some forgotten baseline code
* Add some basic hooks for use by future Dashboard plug-ins.
* Add a registry for creating hooks and callbacks.
* Oops: Remove report baseline functionality
* Rename baseline-diff-report CSS classes and IDs to be expandable-list
* (#6090) Improved auto-selection of "specific baseline".
* (#6072) Moved baseline inspection link underneath "Recent Inspections"
* (#6095) Render proper error messages when diffing against a baseline that can't be found
* (#6069) Fixed unique ids in the report group diff view.
* maint: Use new factory_girl syntax to improve a test
* maint: Refresh the vendored gem specifications
* maint: replace object_daddy with factory_girl
* maint: Fix a case where the alphabetically first baselines may not appear
* Maint: Moved colorbox.css and image files to be compatible with production environment
* (#5869) Extract baseline selector into a partial
* (#5869) Add new baseline selector to the node group page
* (#5869) Rework the baseline selector for report show page
* (#5869) Add a /reports/baselines action to retrieve baselines
* maint: add a view test to motivate reverting diff expand_all
* maint: Added combobox widget, to replace autocomplete plugin
* maint: upgraded jquery-ui to 1.8.9
* Maint: Add JQuery UI animation to expand/collapse widgets.
* (#6024) Show filebucket popup on diff screen, too
* (#6024) Click md5s to popup file bucket contents on reports
* maint: Privatize string helper
* (#5865) Further improvements and bug fixes to the "search inspect reports" page
* Revert "Maint: Removed show_expand_all_link variable"
* (#5785) Removed some redundancy from report view.
* Maint: Removed show_expand_all_link variable
* (#5867) Add ability to diff a node_group against a single baseline
* (#5867) Only show baseline comparison UI when there are baselines
* (#5867) Order nodes by name on node_group diff-against-baseline page
* (#5171) Added a user interface for viewing file content differences
* (#5865) Rework search reports page
* (#5866) Get a consolidated report for baseline diffs in a group
* (#5866) Split dividing diff into pass and fail into a method
* maint: Fixing bad view logic related to enable_read_only_mode
* maint: Remove unused, user related views
* (#5880) Renamed diff_summary to diff now that there is a single view for all diffing.
* (#5880) Redesigned UI for diffing inspect reports
* (#5865) Search for files differing from the expected checksum
* (#5171) Allow Dashboard to contact a file bucket server for file diffs
* Maint: made PuppetHttps.get handle errors
* Maint: check that report deserialization fills in change_count
* (#5900) Added missing migration
* (#5900) Added support for the resource status "failed" attribute in reports.
* (#5889) Add pagination to the file search page
* (#5863) Inspect report search defaults to only searching the most recent report
* (#5863) inspect and apply reports are allowed to happen at the same timestamp
* (#5863) rename latest_report to latest_apply_report
* maint: Add the certs directory to .gitignore
* (#5874) Git rid of unused assignments and services tables and models
* (#5744) Change large columns from string to text
* (#5864) Display "no results" if a file search returns an empty list.
* (#5861) Make a enable_read_only_mode setting
* maint: Remove redundant will_paginate plugin, and just use the gem
* maint: Fetch metrics all at once on reports index page
* maint: Make pagination only appear when needed
* (#5540) Inspect reports no longer affect the status of a node
* (#5540) Make run time chart only consider 'apply' reports
* (#5540) Make daily run status chart only consider 'apply' reports
* (#5540) Do not allow 'apply' reports to be made baselines
* (#5540) Split report tables into inspect and apply
* (#5540) Require a kind for reports
* (#5172) Add link to reports search page
* (#5172) Add a page for searching reports
* (#5172) Add a route and controller action for searching reports by file title/content
* (#5172) Add scopes for finding resource_statuses by file title/content
* (#5743) Fix problems with supporting report_format 2
* (#5743) Added resource_statuses' skipped attribute to the database.
* (#5743) Added a test to verify that failed reports don't have a bogus time/total metric added to them when they are transformed from format 1 to 2.
* (#5743) Cleaned up code for detecting status of reports when translating format 1 to format 2.
* (#5743) Made the report format 1->2 transformer convert metric names to strings.
* (#5743) Removed tags from resource_events, since they were redundant.
* (#5743) Added audited and historical_value to the schema for reports and updated the report format 1->2 transformer to create these attributes.
* (#5743) Removed source_description from resource_statuses and events in both the report hashes and in the database.
* (#5743) Removed resource_type and title from to_hash for format 0 and 1 reports, added to the format 1->2 report transformer.
* (#5743) Added out_of_sync_count to the schema and to the 1->2 report transformer.
* (#5743) Tested that the report format 1->2 transformation converts kind correctly.
* (#5743) Tested that the report format 1->2 conversion sets puppet_version properly.
* (#5743) Test that the format 1->2 report transformation handles configuration_version properly.
* (#5743) Added to the report version 0->1 transformation to add puppet version information to logs.
* (#5743) Created the mixins for interpreting reports in format 2.
* (#5743) Removed kind, configuration_version, and puppet_version from the hash reperesentation of version 1 reports, since these reports don't contain those attributes.
* (#5743) Changed resource_statuses to be represented as a hash internally while transforming reports.
* (#5743) Added log version to the hash for version 0 and 1 reports.
* (#5743) Added resource_status version to the hash for format 1 reports.
* (#5743) Removed kind, puppet_version, and configuration_version from the hash generated from format 1 reports, since those fields are not present in format 1 reports.
* (#5743) Removed dead code.
* (#5743) Add puppet_version, configuration_version, and kind to the 0->1 report transformer.
* (#5743) Remove kind, puppet_version, and configuration_version from the hash generated by 0.25.x reports, since those fields weren't present in 0.25.x reports.
* Prep work for #5743.  Test version and status inference.
* Prep for work on #5743.  Removed all pending spec tests.
* (#5725) Update schema.rb to reflect the removal of the user table
* maint: report title is a partial
* (#5174) Colorize diffs
* (#5174) Unchanged resources appear on diff page
* (#5174) UI to choose a baseline to diff against
* (#5174) named scope to find baseline reports
* (#5174) added named scopes to separate apply and inspect reports
* (#5174) add images for baseline and inspect
* (#5174) make_baseline action is exposed in UI
* maint: 2.6 reports should respect @kind if they have it
* (#5174) Node has a Baseline Report
* (#5739) Removing unused vendored plugin resources_controller
* (#5739) Removing unused vendored gem stringex
* (#5739) Removing unused vendored gem has_scope
* (#5739) Removing unused vendored plugin jrails
* (#5725) Remove user related code
* Fix #5573.  Diff now handles missing resources/properties.
* (#5493) Use the hash version of reports to create Reports
* (#5493) Implemented ReportTransformer to bring reports to the latest format
* (#5493) Added Puppet::Transaction::Report#to_hash method
* maint: Don't recommend development head for installation
* (#5535) Rake task to migrate old database yaml to the new reports schema
* (#5543) Fix rake reports:import task
* maint: group create_from_yaml tests
* maint: Remove dead metric view code.
* maint: Get rid of generate_for usage and method
* (#5459) Use resource_status.name method
* (#5459) Correctly retrive total_time
* (#5459) Fix rake db:seed to use new create_from_yaml
* (#5459) Modify the slow success migration not to be slow
* (#5459) Handle errors in report upload
* (#5459) Added a test of resource_status.name
* (#5459) Added a test of importing 0.25 reports
* (#5459): Make create_from_yaml transactional
* (#5459) Convert from yaml in the report column to a schema
* maint: removed unnecessary REPORTS_META constant
* maint: Rename failed? and changed? to not conflict with ActiveRecord methods
* maint: remove unused formats for reports/nodes
* (#5361) Add a new /reports/upload URL, and optionally disable old url
* (#5170) Screens for diff and diff summary
* (#5174) Add a method to allow reports to be diffed
* (#4972) Add Rake task for creating the release tar-balls
* (#5116) Add spec for PagesController#home
* (#5116) Fixed unreported nodes displaying as recently-reported
* (#5116) Add specs for hiddenness
* (#5116) Add ability to hide nodes
* (#5379) Reset SETTINGS to defaults before every test
* maint: Fix HTML table structure
* Feature #5142 Per-Page parameter
* Maint: Removed accidental duplication in Debian packaging
* (#5116) Clean up specs for NodeController
* Added Ubuntu dist to changelog to update packaging
* Feature #5117: custom_logo_url will replace the Puppet Dashboard logo
* (#4623) Sort timeline_events in the order they were created
* (#4623) Define comparator for NodeGroup and NodeClass
* maint: Suppress ActiveSupport deprecation warnings
* maint: Remove useless test
* (#5120) Disable editing nodes when external node classification is disabled
* maint: Remove dead code and cleanup whitespace
* (#4401) Modified status query to use the Rails time zone
* (#4601) Fixes table rendering on group/class/node pages
* (#4661) Fix broken specs for shared behaviors
* (#4661) Classes/groups/nodes are now sorted appropriately
* (#4605) Renamed date_format setting to datetime_format and added separate date_format.
* (#4475) Fixed documentation for passing environment variables to the external node script
* maint: Fix setting dependent spec
* (#4605) Fix timezone issues with chart grouping and start
* (#4605) Allow date_format to be set in settings.yml
* (#4605) Tests for the time_zone setting
* (#4605) Added Time zone setting to settings.yml.
* (#3435) Fix broken migration
* (#5278) Settings will now individually fallback to values in settings.yml.example
* (#5278) Remove unused arguments to SettingsReader.read
* (#5278) Rename settings-sample.yml to setting.yml.example
* (#5278) Add specs for existing settings functionality
* Refine #4475 Add environment variables for all external_node settings
* Feature #4475 Configurable URL in external_node script
* (#4881) Added daily_run_history_length setting
* (#4881) Add a spec for the daily run history partial
* (#3435) Add Node model stub to make migration safer
* (#4474) Add setting to disable node classification
* Maint: Move "Local-branch:" info below "---"
* (#4874) Add setting for no_longer_reporting_cutoff
* (#3435) Reports now have "changed/unchanged" as statuses
* Maint: add "Local-branch:" info to mails sent by "rake mail_patches"
* (#4345) Modified README to include workaround for Puppet bug #5244.
* maint: require activesupport from config/environment.rb
* (#4553) Add log rotation to config/environment.rb
* (#4620) Never reported nodes are not considered failing
* (#5104) Failed catalog compiles now report as failed
* (#4636) Add file/line to log and event messages
* (#4514) Add table of resource events to report view
* (#4514) Support total time for 2.6 reports
* (#4514) Support config retrieval time for 2.6 reports
* (#4688) Update README to explain SSL configuration
* (#4688) Add HTTPS support to bin/external_node
* maint: rename cert rake tasks to be in the "cert" namespace
* (#4688) Include example SSL settings for apache
* Maint: Remove delegation from PuppetHttps to Settings
* (#4688) Get CA cert and CRL list as part of cert rake tasks
* (#3531) Moved node/group methods to NodeGroupGraph
* (#3531) Rename "list" methods and remove unused methods/files
* (#3531) Don't leave source for params/groups/classes blank
* (#3531) Remove unused NodeGroupCycleError file
* (#3531) Show sources for nodes/group/classes/parameters
* (#3531) Add helper methods for dealing with the node group graph
* (#5199) Add setting to disable the inventory service features
* (#5133) Document auth.conf security for inventory service
* (#2986) Add node search based on facts
* (#2933) Add missing partial for facts
* (#2933) Add table of facts to node pages
* Tightened up permissions on the public/private key pair that is used to contact the master.
* (#4604) Dashboard now has a place for site-specific settings
* (#5133) Made Dashboard able to fetch node facts from inventory REST API.
* (#5149) Added rake tasks to manage certificate and public/private key pair
* (#4880) Fixed validation of new reports
* [#4541] Route to nodes using id instead of name.

v1.0.4
------

* MIGRATION: Fixed truncation of long reports and deleted these invalid records. Please reimport your reports (see README) after migrating to readd these deleted reports.
* MIGRATION: Fixed slow database queries and improved table indexes to speed up the home page, reports listing page, site-wide sidebar, nodes counts, and selection of nodes over time.
* MIGRATION: Fixed orphaned records left behind when classes or groups were deleted, and removed these orphans from the database.
* MIGRATION: Fixed duplicate membership records by removing them and preventing new ones from being added, e.g. a node belongs to the same class or group multiple times.
* Fixed user interface for specifying classes and groups to work with standards-compliant browsers, autocomplete on keystroke rather than submitting, etc.
* Fixed default node search, it was incorrectly using the "ever failed" node query rather than the "all" nodes query.
* Fixed .rpm and .deb packages to include all required files, declare all dependencies, set correct permissions and include working startup scripts.
* Fixed run-failure chart to correctly count the reports by day.
* Fixed run-time chart to correctly display its unit-of-measure labels as seconds, not milliseconds.
* Fixed report display and sorting to use the time the report was created by a client, rather than the time it was imported.
* Fixed class validations to accept valid Puppet class names, including those with correctly-placed dashes, double-colons and numbers.
* Fixed cycle exception caused when a node belonged to two or more groups that inherited a single, common group.
* Fixed parameter inheritance so that a node belonging to a group can see the parameters it inherited from its groups' ancestors.
* Fixed parameter collision to display errors if the same parameter was defined differently by groups at the same level of inheritance (e.g. both parents).
* Fixed views to display all dates and times in the same timezone and format.
* Fixed class edit form to use new-style form that can display error messages.
* Fixed node to recalculate its latest report if the current report record was deleted.
* Fixed external node classifier so Puppet can classify unknown nodes using its local file-based classification, rather than halting with errors.
* Fixed node, class, and group listing pages to describe the current search and non-matches correctly.
* Fixed views to generate all internal links relative to RAILS_ROOT enabling the site to be served from sub-URIs (Ex: example.com/dashboard/).
* Fixed documentation for adding the EPEL repository on CentOS and RHEL hosts.
* Fixed documentation to use sh-compatible commands and explain that this is the expected shell for commands.
* Fixed exceptions on the node's create and edit forms if the user submitted the form with a blank name.
* Fixed release notes styling to properly indent bullet points.
* Improved node classification to display useful error messages when there's a problem.
* Improved page headings to display the type of resource shown, e.g. "Node: mynodename.net"
* Improved graph legends to more prominently show their intervals.
* Added task to optimize the database tables which can be run using `rake RAILS_ENV=production db:raw:optimize`.
* Added documentation describing how to upgrade to a new Puppet Dashboard release.
* Added documentation describing how to set the Puppet Dashboard's filesystem ownership and permissions.
* Added documentation describing how to prune old reports and fixed the script for pruning these to use the time the report was created rather than imported.
* Added documentation describing some simple ways to improve the application's performance, see README.
* Added documentation describing how to locate error logs to help debug and report problems.

v1.0.3
------

* MIGRATION: Added cache with node's latest report and success status to improve performance.
* Fixed exceptions and messages shown if no items to display on groups, classes and reports pages.
* Fixed node failures causing them to be listed as failed forever.
* Fixed unintended dependencies on external Puppet, Rake and JSON gems.
* Fixed and improved the README documentation with better installation instructions.
* Fixed chart rendering issues, including it being too wide to fit on the screen.
* Fixed confusing headers for node listings shown as part of other pages.
* Fixed display of empty entries in nodes, reports, classes and groups
* Fixed node categorization, added new categories to "Nodes" sidebar and highlighting of errors.
* Fixed styling of buttons, icons, warning sections, autocomplete, etc.
* Added database check to ensure it's running the latest schema.
* Added rake tasks to dump and restore the database, see README for details.
* Added support for accepting Puppet 2.6 reports, with limited support for displaying their contents.
* Improved performance by concatenating JavaScript and CSS files together.
* Improved performance of many pages by eliminating and optimizing database queries.
* Improved reports by displaying logs colored and sorted by severity and metrics with totals in bold.
* Removed unused checkboxes.

v1.0.2
------

* Fixed exceptions on the node reports page.
* Fixed chart headers so they are shown only once.
* Fixed chart formatting errors.
* Fixed homepage warning message boxes to look like errors.
* Fixed errors in documentation.
* Added userful menu bar.
* Added version number to menu bar and release notes page.
* Added missing "favicon.ico", the lack of which was filling logs with errors.
* Removed unused "Register" and "Log in" links.

v1.0.1
------

* Fixed exception in display of audit log messages
* Fixed deletion of nodes to remove their reports, eliminating orphans
* Fixed exception on node group pages if they had associated classes or groups
* Fixed unwanted pagination of JSON and YAML results
* Fixed reporting of successful and failed nodes
* Added deletion of single reports
* Added labels and placeholders to form fields
* Added local copies of all JavaScript files
* Added run status chart to node list pages (all, successful, failed)
* Added searching to node, class and group index pages
* Added tooltips to node and report status indicators
* Improved README's installation and configuration instructions
* Improved sidebar with links to classes and groups, added it to homepage
* Improved tabular display of nodes, groups and classes
* Removed empty reports.css to make packagers happy
* Removed loading of seed data by default
* Updated UI with status icons, improved typography and spacing, more noticeable buttons
* Updated packaging information for DEB and RPM
