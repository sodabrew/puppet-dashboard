Puppet Dashboard Release Notes
==============================

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
