---
layout: default
title: "Dashboard Manual: Maintaining"
---

Maintaining Puppet Dashboard
=====

This is a chapter of the [Puppet Dashboard 1.2 manual](./index.html).

#### Navigation

* [Installing Dashboard](./bootstrapping.html)
* [Upgrading Dashboard](./upgrading.html)
* [Configuring Dashboard](./configuring.html)
* **Maintaining Dashboard**
* [Using Dashboard](./using.html)
* [Rake API](./rake_api.html)

* * * 

Overview
--------

Puppet Dashboard exposes most of its functionality through its web UI, but it has a number of routine tasks that have to be performed on the command line by an admin. This chapter is a brief tour of some of these tasks.

Note that **all rake tasks should be performed from a shell in the directory that contains Dashboard's code.** Any relative paths mentioned below refer to locations within this directory. If you are running Dashboard in the recommended "production" environment, note that **Rails does not consider production its default environment,** and you **must specify it manually** with the `RAILS_ENV` environment variable when running any rake tasks.

Importing Pre-existing Reports
-----

If your puppet master has stored a large number of reports from before your Dashboard came online, you can import them into Dashboard to get a better view into your site's history. If you are running Dashboard on the same server as your puppet master and its reports are stored in `/var/puppet/lib/reports`, you can simply run:

    $ sudo -u puppet-dashboard rake RAILS_ENV=production reports:import

Alternately, you can copy the reports to your Dashboard server and run:

    $ sudo -u puppet-dashboard rake RAILS_ENV=production reports:import REPORT_DIR=/path/to/your/reports

**Note that this task can take a very long time,** depending on the number of reports to be imported. You can, however, safely interrupt and re-run the task, as the importer will automatically skip reports that Dashboard has already imported. 

Optimizing the Database
-----

Since Dashboard turns over a lot of data, its MySQL database should be periodically optimized for speed and disk space. Dashboard has a rake task for doing this:

    $ sudo -u puppet-dashboard rake RAILS_ENV=production db:raw:optimize

You should **optimize Dashboard's database monthly,** and we recommend creating a cron job to do so.

InnoDB is Taking Up Too Much Disk Space
-----

Over time, the innodb database can get quite hefty, especially in larger deployments with many nodes. In some cases it can get large enough to consume all the space in `var`, which makes bad things happen. When this happens, you can follow the steps below to slim it back down.

1. Move your existing data to a backup file by running: `# mysqldump -p --databases {DASHBOARD'S DATABASE} {INVENTORY SERVICE DB (if present)} > /path/to/backup.sql`

2. Stop the MySQL service

3. Remove *just* the dashboard-specific database files. If you have no other databases, you can run `# cd /var/lib/mysql # rm -r ./ib* # rm -r ./console*`. *Warning:* this will remove everything, including any db's you may have added.

4. Restart the MySQL service.

5. Create new, empty databases by running this rake task: `# rake -f <FULL PATH TO DASHBOARD'S DIRECTORY>/Rakefile RAILS_ENV=production db:reset`.

6. Repopulate the databases by importing the data from the backup you created in step 1 by running: `# mysql -p < /path/to/backup.sql`.


Cleaning Old Reports
----------------

Reports will build up over time, which can slow Dashboard down. If you wish to delete the oldest reports, for performance, storage, or policy reasons, you can use the `reports:prune` rake task. 

For example, to delete reports older than 1 month:

    $ sudo -u puppet-dashboard rake RAILS_ENV=production reports:prune upto=1 unit=mon

If you run 'rake reports:prune' without any arguments, it will display further usage instructions.

Although this task **should be run regularly as a cron job,** the frequency with which it should be run will depend on your site's policies.

A simple cron job to run the task monthly can be installed by running:

    $ sudo -u puppet-dashboard rake cron:cleanup



Reading Logs
---------

Dashboard may fail to start or display warnings if it is misconfigured or encounters an error. Details about these errors are recorded to log files that will help diagnose and resolve the problem.

You can find the logs in Dashboard's `log/` directory. You can customize your log rotation in `config/environment.rb` to devote more or less disk space to them.

If you're running Dashboard using Apache and Phusion Passenger, the Apache logs will contain higher-level information, such as severe errors that prevent Passenger from starting the application. 

Database backups
----------------

Although you can back up and restore Dashboard's database with any tools, there are a pair of rake tasks which simplify the process. 

### Dumping the Database

To dump the Puppet Dashboard `production` database to a file called `production.sql`:

    $ sudo -u puppet-dashboard rake RAILS_ENV=production db:raw:dump

Or dump it to a specific file:

    $ sudo -u puppet-dashboard rake RAILS_ENV=production FILE=/my/backup/file.sql db:raw:dump

### Restoring the Database

To restore the Puppet Dashboard from a file called `production.sql` to your `production` environment:

    $ sudo -u puppet-dashboard rake RAILS_ENV=production FILE=production.sql db:raw:restore


* * * 

#### Navigation

* [Installing Dashboard](./bootstrapping.html)
* [Upgrading Dashboard](./upgrading.html)
* [Configuring Dashboard](./configuring.html)
* **Maintaining Dashboard**
* [Using Dashboard](./using.html)
* [Rake API](./rake_api.html)
