package CtrlNest::Schema::Result::Migrations;

use warnings;
use strict;

use base qw( DBIx::Class::Core );

# Convert timestamps to DateTime objects
__PACKAGE__->load_components(qw/InflateColumn::DateTime/);

# Creates the table
__PACKAGE__->table('migrations');

# Add all the table' columns
__PACKAGE__->add_columns(
  id => {
    data_type         => 'integer',
    is_auto_increment => 1
  },

  version => {
    data_type   => 'char',
    size        => 5,
    is_nullable => 0
  },

  code_name => {
    data_type   => 'varchar',
    size        => 24,
    is_nullable => 0
  },

  applied_at => {
    data_type     => 'timestamptz',
    timezone      => 'UTC',
    set_on_create => 1,
    default_value => \'CURRENT_TIMESTAMP',
  },
);

# Add primary key constraint
__PACKAGE__->set_primary_key('id');

# Add unique constraints
__PACKAGE__->add_unique_constraint([qw( version )]);

1;
