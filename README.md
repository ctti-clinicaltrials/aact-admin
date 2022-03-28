# AACT
Administer AACT: Aggregated Analysis of ClinicalTrials.gov

## Getting Started

You should always setup AACT Core before setting up AACT Admin. AACT Admin relies on AACT Core. So if you haven’t set up AACT Core yet, please do so now. [aact core](https://github.com/ctti-clinicaltrials/aact)  
Make sure you've set values for the environmental variables
| Variable | Explanation |
| ------------ | ------------ |
| `AACT_DB_SUPER_USERNAME=<superuser_name>` | This is a database superuser that is used within AACT to make database changes. |  
| `AACT_PASSWORD=<superuser_password>` | This is a database superuser password created to verify the database superuser. |
| `AACT_PUBLIC_DATABASE_NAME=aact` | This is the AACT public database name that the database superuser will be accessing. |  
| `PUBLIC_DB_USER=<superuser_name>` | This is a database superuser that is used to access the production `aact-pub` database. |  
| `PUBLIC_DB_PASS=<superuser_password>` | This is a database superuser password created to verify the database superuser. |  
| `PUBLIC_DB_HOST=<public_host>` | This is the public database hostname used in the connection string to the production `aact-pub` database. Under most circumstances, we can use `aact-db.ctti-clinicaltrials.org` as the public-host. |
| `AACT_ALT_PUBLIC_DATABASE_NAME=aact_alt` | This is the AACT alternate public database name that the database superuser will be accessing. It is used to for staging purposes that allows testing of the database before restoring to AACT. |
| `AACT_CORE_DATABASE_URL=<postgresql://[postgres-user]:[postgres-password]@[hostname]:[port]/[dbname]>` | Connection string to the aact-core database. This allows us to connect to this database from aact-admin. The postgres-user and postgres-password are the superuser-name and superuser-password that you have created in the postgres database that comes with PostgreSQL. Under most circumstances, we can use `localhost` as the hostname and `5432` as the port. |  
| `AACT_QUERY_DATABASE_URL=<postgresql://[postgres-user]:[postgres-password]@[hostname]:[port]/[dbname]>` | Connection string to the production aact-pub database that users query. This allows us to query this database from aact-admin. The postgres-user and postgres-password are the username and password that you have created at `https://aact.ctti-clinicaltrials.org`. Under most circumstances, we can use `aact-db.ctti-clinicaltrials.org` as the hostname and `5432` as the port. |

These variables should have been set when you setup AACT Core. If any are missing you should add them to where you store your variables (for instance ".bash_profile" or ".zshrc").  

Be sure to call `source` on the file where your passwords are. Example `source ~/.bash_profile` so they are reloaded into the terminal.   

You also should have created aact_alt when setting up AACT Core. But if you didn't, you will need to add it now. So enter the psql shell to create it if it had not been created already.  

- `psql postgres -U <super_username>`  

- `\l`  if it's listed, you can exit the shell now. If it is missing, then create it.  

- `template1=# create database aact_alt;`  

- `template1=# \q` (quit out of postgres)  

- Clone the aact-admin repo.  

- `cd` into the aact-admin directory  

- run `bundle install` (bundle version should be '~> 1.17.3')  

if you run into issues with bundle installing `libv8` and the `rubyracer` on a mac you can follow these steps
`brew install v8-315`  
`gem install libv8 -v '3.16.14.19' -- --with-system-v8`  
`gem install therubyracer -- --with-v8-dir=/usr/local/opt/v8@3.15`    

- Setup the databases and database privileges  
`bin/rake db:create`  
`bin/rake db:create RAILS_ENV=test`  
`bin/rake db:migrate`  
`bin/rake db:migrate RAILS_ENV=test`  
`bin/rake db:setup_read_only`  
`bin/rake db:setup_read_only RAILS_ENV=test`  
<br>  

- lastly you'll need to copy the contents from "public/documentation" to "public/static/documentation"
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
