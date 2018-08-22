---
layout: default
title: Dashboard UI — Node Status
---

In Puppet Dashboard, every node is in one of six states:

- <span style="font-family: Helvetica, Arial, Verdana; font-size: larger; color: #888;">Unresponsive:</span> This node hasn't reported to the puppet master recently; something may be wrong. The cutoff for considering a node unresponsive defaults to one hour, and can be configured in `settings.yml` with the `no_longer_reporting_cutoff` setting.
- <span style="font-family: Helvetica, Arial, Verdana; font-size: larger; color: #c21;">Failed:</span> During its last Puppet run, this node encountered some error from which it couldn't recover. Something is probably wrong, and investigation is recommended.
- <span style="font-family: Helvetica, Arial, Verdana; font-size: larger; color: #e72;">Pending:</span> During its last Puppet run, this node _would_ have made changes, but it was either running in no-op mode or found a discrepancy in a resource whose `noop` metaparameter was set to `true`. 
- <span style="font-family: Helvetica, Arial, Verdana; font-size: larger; color: #069;">Changed:</span> This node's last Puppet run was successful, and changes were made to bring the node into compliance. 
- <span style="font-family: Helvetica, Arial, Verdana; font-size: larger; color: #093;">Unchanged:</span> This node's last Puppet run was successful, and it was fully compliant; no changes were necessary. 
- <span style="font-family: Helvetica, Arial, Verdana; font-size: larger; color: #aaa;">Unreported:</span> Although Dashboard is aware of this node's existence, it has never submitted a Puppet report. It may be a newly-commissioned node, it may have never come online, or its copy of Puppet may not be configured correctly.

