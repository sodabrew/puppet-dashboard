---
layout: default
title: "Dashboard Manual: Upgrading"
---

Upgrading Puppet Dashboard
========

This is a chapter of the [Puppet Dashboard 1.2 manual](./index.html).

#### Navigation

* [Installing Dashboard](./bootstrapping.html)
* **Upgrading Dashboard**
* [Configuring Dashboard](./configuring.html)
* [Maintaining Dashboard](./maintaining.html)
* [Using Dashboard](./using.html)
* [Rake API](./rake_api.html)

[dbbackups]: ./maintaining.html#database-backups

* * * 

Overview
--------

Upgrading Dashboard from a previous version generally consists of the following:

* Stopping the webserver and delayed jobs workers
* [Upgrading the Dashboard code itself](#upgrading-code)
* [Running any new database migrations](#running-database-migrations)
* Restarting the webserver and delayed jobs workers

In addition, there are several tasks you must take into account when upgrading from certain versions. 

* [Upgrading from pre-1.2 versions](#upgrading-from-versions-prior-to-120)
* [Upgrading from pre-1.1 versions](#upgrading-from-versions-prior-to-110)

Note that **all rake tasks should be performed from a shell in the directory that contains Dashboard's code.** Any relative paths mentioned below refer to locations within this directory. If you are running Dashboard in the recommended "production" environment, note that **Rails does not consider production its default environment,** and you **must specify it manually** with the `RAILS_ENV` environment variable when running any rake tasks.

Upgrading Code
--------------

### From Packages

Dashboard installations that used Puppet Labs' packages are the easiest to upgrade. If you installed Dashboard with Yum: 

    $ sudo yum update puppet-dashboard

If you installed it with APT:

    $ sudo apt-get update
    $ sudo apt-get install puppet-dashboard


If you installed it from an RPM package file:

    $ sudo rpm -Uvh puppet-dashboard-1.2.0.noarch.rpm

If you installed it from a Deb package file:

    $ sudo dpkg -i puppet-dashboard-1.2.0_all.deb

### From Git

Upgrading from Git is relatively straightforward, although you will have to re-chown all of Dashboard's files after performing the upgrade.

First, fetch data from the remote repository:

    $ git fetch origin

Before checking out the new release, make sure that you haven't made any changes that would be overwritten:

    $ git status

Dashboard's `.gitignore` file should ensure that your configuration files, certificates, temp files, and logs will be untouched by the upgrade, but if the status command shows any new or modified files, you'll need to preserve them. You could just copy them outside the directory, but the easiest path is to use git stash:


    $ git add {list of modified files}
    $ git stash save "Modified files prior to 1.2.0 upgrade"

After that, you're clear to upgrade:

    $ git checkout v1.2.0

(And if you had to stash any edits, you can now apply them:

    $ git stash apply

If they don't apply cleanly, you can abort the commit with `git reset --hard HEAD`, or [read up][mergeconflict] on how to resolve Git merge conflicts.)

Finally, re-chown all Dashboard files to the puppet-dashboard user:

    $ sudo chown -R puppet-dashboard:puppet-dashboard ./*

[mergeconflict]: http://book.git-scm.com/3_basic_branching_and_merging.html

### From Tarballs

If you originally installed Dashboard from a source tarball, you'll need to either pick out all of your modified or created files and transplant them into the new installation, or convert your installation to Git; either way, you should back up the entire installation first.

To convert an existing Dashboard installation to a Git repo, do something like the following, replacing {version tag} with the version of Dashboard you originally installed: 


    git init
    rm .gitignore
    wget https://raw.github.com/puppetlabs/puppet-dashboard/{version tag}/.gitignore
    git add .
    git commit -m "conversion commit"
    git branch original
    git remote add upstream git://github.com/puppetlabs/puppet-dashboard.git
    git fetch upstream
    git reset --hard tags/{version tag}
    git merge --no-ff original
    git reset --soft tags/{version tag}
    git stash save "Non-ignored files which were changed after the original installation."
    git checkout tags/v1.2.0
    git stash apply

As with a standard Git upgrade, you'll need to re-chown all Dashboard files to the puppet-dashboard user:

    $ sudo chown -R puppet-dashboard:puppet-dashboard ./*

Running Database Migrations
---------------------------

Puppet Dashboard's database schema changes as features are added and improved, and it needs to be updated after an upgrade. You may want to backup your database before you do this --- see the [database backups][dbbackups] section of the maintaining chapter for further details.

DB migrations are done with a rake task, and should be simple and painless when upgrading between any two official releases of Dashboard.

    $ sudo -u puppet-dashboard rake db:migrate RAILS_ENV=production 

Remember that Rails does not consider "production" its default environment, so you must specify it manually for all rake tasks unless your `RAILS_ENV` environment variable is set or you are using the same database in the production and development environments. 

You'll need to run `db:migrate` once for each environment you use. The `db:migrate` task can be safely run multiple times in the same environment.

After upgrading the code and the database, be sure to restart Dashboard's webserver and delayed jobs workers.


Upgrading From Versions Prior to 1.2.0
--------------------------------------

For reasons of speed and scalability, Dashboard 1.2 introduced a delayed job processing system. Dashboard won't lose any data sent by puppet masters if you don't run these delayed jobs, but they're necessary for analyzing reports and keeping the web UI up-to-date. You'll need to configure and run at least one worker process, and we recommend running exactly one process per CPU core.

Currently, the best way to manage these processes is with the `script/delayed_job` command, which can daemonize as a supervisor process and manage the requested number of workers. To start four workers and the monitor process:

    $ sudo -u puppet-dashboard env RAILS_ENV=production script/delayed_job -p dashboard -n 4 -m start

See [the delayed jobs section](./bootstrapping.html#starting-and-managing-delayed-job-workers) of the installation chapter for more information.

Upgrading From Versions Prior to 1.1.0
--------------------------------------

In version 1.1.0, Dashboard changed the way it stores reports, and any reports from the 1.0.x series will have to be converted before they can be displayed or analyzed by the new version. 

Since this can potentially take a long time, depending on your installation's report history, it isn't performed when running `rake db:migrate`. Instead, you should run:

    $ sudo -u puppet-dashboard rake reports:schematize RAILS_ENV=production

This task will convert the most recent reports first, and if it is interrupted, it can be resumed by just re-running the command. 

* * * 

#### Navigation

* [Installing Dashboard](./bootstrapping.html)
* **Upgrading Dashboard**
* [Configuring Dashboard](./configuring.html)
* [Maintaining Dashboard](./maintaining.html)
* [Using Dashboard](./using.html)
* [Rake API](./rake_api.html)
