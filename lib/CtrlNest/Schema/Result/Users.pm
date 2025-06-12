package CtrlNest::Schema::Result::Users;

use warnings;
use strict;

use base qw( DBIx::Class::Core );

# Convert timestamps to DateTime objects
__PACKAGE__->load_components(qw/InflateColumn::DateTime/);

# Creates the table
__PACKAGE__->table('users');

__PACKAGE__->add_columns(
  id => {
    data_type         => 'integer',
    is_auto_increment => 1,
  },

  username => {
    data_type   => 'varchar',
    size        => 50,
    is_nullable => 0,
  },

  password => {
    data_type   => 'char',
    size        => 60,
    is_nullable => 0,
  },

  role => {
    data_type   => 'varchar',
    size        => 10,
    is_nullable => 0,
  },

  created_at => {
    data_type     => 'timestamptz',
    timezone      => 'UTC',
    set_on_create => 1,
    default_value => \'CURRENT_TIMESTAMP',
  },
);

# Add primary key constraint
__PACKAGE__->set_primary_key('id');

# Add unique constraints
__PACKAGE__->add_unique_constraint([qw( username )]);

# Link this Result to it's ResultSet
__PACKAGE__->resultset_class('CtrlNest::Schema::ResultSet::Users');

1;
