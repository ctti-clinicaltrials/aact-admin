# AACT
Administer AACT: Aggregated Analysis of ClinicalTrials.gov

## Getting Started

At the moment you have to setup aact before setting up aact-admin. So make sure you do that first.
* [aact core](https://github.com/ctti-clinicaltrials/aact)
Make sure you've set values for the environmental variables AACT_DB_SUPER_USERNAME and AACT_PASSWORD

You may still need to create aact_alt. So enter the psql shell to check if it's there and add it if it's not.

`psql template1`

`\l`
if it's listed, you can exit the shell now. If it is missing, then create it.

`template1=# create database aact_alt;`

`template1=# \q` (quit out of postgres)

Clone the aact-admin repo.

cd into the aact-admin directory and run the setup files

For mac you can run the setup file in the terminal

`./bin/mac_setup`

If you aren't on a mac, then install libv8 and therubyracer according to the method for your system.
Then run the generic setup script:

`./bin/setup`

## Environment variables

After running either setup scrupt, you'll have a `.env` file that contains an empty template for the environment variables you'll need. These variables are copied from `.env.example`

Setup the folders you need with `Util::FileManager.new` in the console

setup the databases with
`RAILS_ENV=test bin/rake db:create`
`bin/rake db:create`
`RAILS_ENV=test bin/rake db:migrate`
`bin/rake db:migrate`

Grant permissions to the read_only role.
`bin/rake db:setup_read_only`
`bin/rake db:setup_read_only RAILS_ENV=test`


## Sanity checks

Sanity checks are a simple way for us to check that the tables in the database have been imported correctly and gives some insight into how the data looks at a high level. Both the daily and full import rake tasks run the sanity check automatically. To run it manually, open up a Rails console and enter `SanityCheck.run`. This will create a record in the `sanity_checks` table with a report represented in JSON.

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
