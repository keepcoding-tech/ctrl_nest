#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';

use DBIx::Class::Migration;

use CtrlNest::Schema;

# Get the action from the command line
my $cmd = shift @ARGV
  or die "Usage: $0 [install|prepare|upgrade|deploy|status|help]\n";

# DB (create connection string)
my $pg_dsn  = $ENV{DBI_DSN};
my $pg_user = $ENV{DBI_USER};
my $pg_pass = $ENV{DBI_PASS};

my $migration = DBIx::Class::Migration->new(
  schema     => CtrlNest::Schema->connect($pg_dsn, $pg_user, $pg_pass),
  target_dir => 'db'
);

if ($cmd eq 'install') {
  $migration->install;
}
elsif ($cmd eq 'prepare') {
  $migration->prepare;
}
elsif ($cmd eq 'upgrade') {
  $migration->upgrade;
}
elsif ($cmd eq 'deploy') {
  $migration->prepare;
  $migration->install;
}
elsif ($cmd eq 'status') {
  $migration->status;
}
elsif ($cmd eq 'help') {
  print <<"HELP";
Usage:
  - install    # installs an existing schema from db/
  - prepare    # prepare new migration
  - upgrade    # upgrades the db without loasing existing data
  - deploy     # deploy schema to a fresh DB
  - status     # print current migration version
HELP
}
else {
  die "Unknown command: $cmd\n";
}

1;
