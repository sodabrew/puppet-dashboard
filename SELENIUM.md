How to run the Selenium acceptance tests
========================================

INTRODUCTION

This document describes the process of running the Selenium acceptance tests
locally. Running the tests remotely (e.g. on a virtual machine) is also
possible, but beyond the scope of this document.

See http://seleniumhq.org/docs/ for more details.

PREREQUISITES

- You must have an instance of Dashboard running
- You must have the selenium-webdriver gem installed 

STEPS

To run the Selenium acceptance tests, do the following:

1. Edit DASHBOARD_ROOT/acceptance/selenium/spec_helper.rb

  - Change $DASHBOARD_BASE_URL to the URL where your instance of Dashboard is
   running

  - Change $DRIVER to the browser you want to use for your tests

2. Run `spec acceptance/selenium/`
