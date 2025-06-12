package CtrlNest::Schema::Result::User;

use warnings;
use strict;

use base qw( DBIx::Class::Core );

################################################################################

# Convert timestamps to DateTime objects
__PACKAGE__->load_components(qw/InflateColumn::DateTime/);

__PACKAGE__->table('users');
__PACKAGE__->add_columns(

  ##############################################################################
  ### Internal
  ##############################################################################

  uid => {
    data_type         => 'integer',
    is_auto_increment => 1,
  },

  ##############################################################################
  ### General
  ##############################################################################

  first_name => {
    data_type   => 'varchar',
    size        => 65,
    is_nullable => 0,
  },

  last_name => {
    data_type   => 'varchar',
    size        => 65,
    is_nullable => 0,
  },

  username => {
    data_type   => 'varchar',
    size        => 65,
    is_nullable => 0,
  },

  email => {
    data_type   => 'varchar',
    size        => 255,
    is_nullable => 0,
  },

  phone => {
    data_type   => 'varchar',
    size        => 15,
    is_nullable => 1,
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

  ##############################################################################
  ### Other Internals
  ##############################################################################

  created_at => {
    data_type     => 'timestamptz',
    timezone      => 'UTC',
    set_on_create => 1,
    default_value => \'CURRENT_TIMESTAMP',
  },
);

################################################################################

__PACKAGE__->set_primary_key('uid');

__PACKAGE__->has_many(
  ac => 'CtrlNest::Schema::Result::AccessCode',
  { 'foreign.created_by' => 'self.uid' },
  {
    cascade_delete => 1
  }
);

__PACKAGE__->add_unique_constraint([qw( username email phone )]);

################################################################################

1;
