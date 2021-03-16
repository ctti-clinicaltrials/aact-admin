# AACT
Administer AACT: Aggregated Analysis of ClinicalTrials.gov

## Getting Started

At the moment you have to setup aact before setting up aact-admin. So make sure you do that first.
Make sure you've set values for the environmental variables AACT_DB_SUPER_USERNAME and AACT_PASSWORD

You may still need to create aact_alt. So enter the psql shell to do so.

`psql template1`

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

re-enter the shell to grant permissions on the ctgov schema

`psql aact -U <your_superuser>`
`template1=# grant connect on database aact to read_only;`

`template1=# grant connect on database aact_alt to read_only;`

`aact=# grant usage on schema ctgov to read_only;`
`aact=# \q`

It assumes you have a machine equipped with Ruby, Postgres, etc. If not, set up
your machine with [this script].

[this script]: https://github.com/thoughtbot/laptop

## Importing studies from clinicaltrials.gov

### Full import

`bundle exec rake import:full:run`

The full import will download the entire dataset from clinicaltrials.gov. This rake task is designed to only work on the first of the month. To run the task and ignore the date, run `bundle exec rake import:full:run[force]`

### Daily import

`bundle exec rake import:daily:run[{days_back}]`

The daily import will check the RSS feed at clinicaltrials.gov for studies that have been added or changed. You can specify how many days back to look in the dataset with the `days_back` argument above. To import changed/new studies from two days back: `bundle exec rake import:daily:run[2]`


## Sanity checks

Sanity checks are a simple way for us to check that the tables in the database have been imported correctly and gives some insight into how the data looks at a high level. Both the daily and full import rake tasks run the sanity check automatically. To run it manually, open up a Rails console and enter `SanityCheck.run`. This will create a record in the `sanity_checks` table with a report represented in JSON.

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
