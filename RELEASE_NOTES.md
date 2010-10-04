Puppet Dashboard Release Notes
==============================

v1.0.4rc2
---------

* MIGRATION: Fixed slow database queries and improved table indexes when counting nodes and selecting nodes over time.
* Fixed node's reports listing page to not throw exceptions.
* Fixed .rpm and .deb packages to include all required files, declare all dependencies, set correct permissions and include working startup scripts.
* Fixed views to display all dates and times in the same timezone and format.
* Fixed views to generate all internal links relative to RAILS_ROOT enabling the site to be served from sub-URIs (Ex: example.com/dashboard/).
* Added documentation describing some simple ways to improve the application's performance, see README.
* Added task to optimize the database tables which can be run using `rake RAILS_ENV=production db:raw:optimize`.

v1.0.4rc1
---------

* MIGRATION: Fixed truncation of long reports and deleted these invalid records. Please reimport your reports (see README) after migrating to readd these deleted reports.
* MIGRATION: Fixed slow database queries on the home page, reports listing page, and site-wide sidebar.
* MIGRATION: Fixed orphaned records left behind when classes or groups were deleted, and removed these orphans from the database.
* MIGRATION: Fixed duplicate membership records by removing them and preventing new ones from being added, e.g. a node belongs to the same class or group multiple times.
* Fixed user interface for specifying classes and groups to work with standards-compliant browsers, autocomplete on keystroke rather than submitting, etc.
* Fixed default node search, it was incorrectly using the "ever failed" node query rather than the "all" nodes query.
* Fixed run-failure chart to correctly count the reports by day.
* Fixed run-time chart to correctly display its unit-of-measure labels as seconds, not milliseconds.
* Fixed report display and sorting to use the time the report was created by a client, rather than the time it was imported.
* Fixed class validations to accept valid Puppet class names, including those with correctly-placed dashes, double-colons and numbers.
* Fixed cycle exception caused when a node belonged to two or more groups that inherited a single, common group.
* Fixed parameter inheritance so that a node belonging to a group can see the parameters it inherited from its groups' ancestors.
* Fixed parameter collision to display errors if the same parameter was defined differently by groups at the same level of inheritance (e.g. both parents).
* Fixed class edit form to use new-style form that can display error messages.
* Fixed node to recalculate its latest report if the current report record was deleted.
* Fixed external node classifier to return a special result when asked for an unknown node so that Puppet can classify it.
* Fixed node, class, and group listing pages to describe the current search and non-matches correctly.
* Fixed documentation for adding the EPEL repository on CentOS and RHEL hosts.
* Fixed documentation to use sh-compatible commands and explain that this is the expected shell for commands.
* Fixed exceptions on the node's create and edit forms if the user submitted the form with a blank name.
* Fixed release notes styling to properly indent bullet points.
* Improved node classification to display useful error messages when there's a problem.
* Improved page headings to display the type of resource shown, e.g. "Node: mynodename.net"
* Improved graph legends to more prominently show their intervals.
* Added documentation describing how to upgrade to a new Puppet Dashboard release.
* Added documentation describing how to set the Puppet Dashboard's filesystem ownership and permissions.
* Added documentation describing how to prune old reports and fixed the script for pruning these to use the time the report was created rather than imported.
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
