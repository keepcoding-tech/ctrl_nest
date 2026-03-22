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
  ### Account
  ##############################################################################

  username => {
    data_type   => 'varchar',
    size        => 64,
    is_nullable => 0,
  },

  email => {
    data_type   => 'varchar',
    size        => 256,
    is_nullable => 0,
  },

  password => {
    data_type   => 'char',
    size        => 60,
    is_nullable => 0,
  },

  role => {
    data_type   => 'varchar',
    size        => 12,
    is_nullable => 0,
  },

  ##############################################################################
  ### Public profile
  ##############################################################################

  avatar_path => {
    data_type   => 'varchar',
    size        => 256,
    is_nullable => 1
  },

  first_name => {
    data_type   => 'varchar',
    size        => 64,
    is_nullable => 0,
  },

  last_name => {
    data_type   => 'varchar',
    size        => 64,
    is_nullable => 0,
  },

  occupation => {
    data_type   => 'varchar',
    size        => 64,
    is_nullable => 1
  },

  bio => {
    data_type   => 'varchar',
    size        => 164,
    is_nullable => 1
  },

  ##############################################################################
  ### Contact
  ##############################################################################

  mobile_phone => {
    data_type   => 'varchar',
    size        => 16,
    is_nullable => 1,
  },

  fix_phone => {
    data_type   => 'varchar',
    size        => 16,
    is_nullable => 1,
  },

  contact_email => {
    data_type   => 'varchar',
    size        => 256,
    is_nullable => 1,
  },

  ##############################################################################
  ### Location
  ##############################################################################

  country => {
    data_type   => 'char',
    size        => 2,
    is_nullable => 1
  },

  region => {
    data_type   => 'varchar',
    size        => 128,
    is_nullable => 1
  },

  city => {
    data_type   => 'varchar',
    size        => 128,
    is_nullable => 1
  },

  address => {
    data_type   => 'varchar',
    size        => 256,
    is_nullable => 1
  },

  zip_code => {
    data_type   => 'varchar',
    size        => 16,
    is_nullable => 1
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

__PACKAGE__->add_unique_constraint([qw( username email )]);

################################################################################

1;
