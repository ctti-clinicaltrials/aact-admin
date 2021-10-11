# AACT
Administer AACT: Aggregated Analysis of ClinicalTrials.gov

## Getting Started

You should always setup AACT Core before setting up AACT Admin. AACT Admin relies on AACT Core. So if you haven’t set up AACT Core yet, please do so now. [aact core](https://github.com/ctti-clinicaltrials/aact)  
Make sure you've set values for the environmental variables `AACT_DB_SUPER_USERNAME` and `AACT_PASSWORD`

You’ll need to add `PUBLIC_DB_USER` and `PUBLIC_DB_PASS` to the same place you put the other variables. You should set these variables to have the same values as your superuser and password to make things easier. Be sure to call `source` on the file where your passwords are. Example `source ~/.bash_profile`.  

You may still need to create aact_alt. So enter the psql shell to check if it's there and add it if it's not.  

- `psql postgres -U <super_username>`  

- `\l`  if it's listed, you can exit the shell now. If it is missing, then create it.  

- `template1=# create database aact_alt;`  

- `template1=# \q` (quit out of postgres)  

- Clone the aact-admin repo.  

- `cd` into the aact-admin directory and run the setup files  
- Setup gems

For mac you can run the setup file in the terminal  

`./bin/mac_setup`  

If you aren't on a mac, then install libv8 and therubyracer according to the method for your system.
Then run the generic setup script:  

`./bin/setup`  

- Setup the databases and database privileges with automatically with `bin/rake setup:databases`  

Or you can do it this way:  
`bin/rake db:create`  
`bin/rake db:create RAILS_ENV=test`  
`bin/rake db:migrate`  
`bin/rake db:migrate RAILS_ENV=test`  
`bin/rake db:setup_read_only`  
`bin/rake db:setup_read_only RAILS_ENV=test`  
<br>  

- lastly you'll need to copy the contents from "public/documentaion" to "public/static/documentation"
***

## Workflow
### Branches:
- master - This is the stable production branch, anything merged to master is meant to be propagated to production. Hot fixes will be merged directly to master, then pulled into dev. All other Pull Requests (PRs) will be merged into dev first.  
- dev - This branch contains the changes for the sprint. It is an accumulation of everything that we believe is working and ready for the next release.  
- feat/AACT-NUM-description - "AACT-Num" refers to the number of the card on Jira. Description is the name of the feature. This is the naming conventions for a feature that you are working on that eventually will be merged to dev once the PR is approved.  
- fix/AACT-NUM-description - This is the naming conventions for a bug fix. The PR will be merged into dev when approved.  
- hotfix/AACT-220-description - This is the naming conventions for an emergency fix. This branches off of master and gets merged into master when the PR is approved because it is a fix that needs to be deployed ASAP.  

Treat dev as the main branch. Only branch off of master if you need to do a hotfix.

### Normal Process
1.  Pick a ticket to work on  
2.  Branch off of dev using the naming convention mentioned above to name your branch  
3.  Work on the feature or bug fix  
4.  Run tests and make sure they pass before creating a PR  
5.  Once complete create a PR to dev  
6.  Request review for the PR from two people  
7.  If there are change requests, makes the changes, run tests and request a review. If not continue to the next step.   
8.  The PR will be approved and merged to dev  
9.  At the end of the sprint the dev will be merged to master (we will add a semantic tag, this is where we will decide which version number to pick)  
10.  Deploy master to production  

### Hotfix Process
1.  Branch off of master using the naming convention mentioned above to name your branch   
2.  Work on the bug fix  
3.  Run tests and make sure they pass
4.  Create PR to master  
5.  Request review for the PR from two people. PR review could be expedited depending on the emergency  
6.  Merge PR to master  
7.  Deploy master to production  
8.  Bring changes into dev (once things stabilize)  
