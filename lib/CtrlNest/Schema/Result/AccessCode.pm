package CtrlNest::Schema::Result::AccessCode;

use warnings;
use strict;

use base qw( DBIx::Class::Core );

################################################################################

# Convert timestamps to DateTime objects
__PACKAGE__->load_components(qw/InflateColumn::DateTime/);

__PACKAGE__->table('access_codes');
__PACKAGE__->add_columns(

  ##############################################################################
  ### Internal
  ##############################################################################

  uid => {
    data_type         => 'integer',
    is_auto_increment => 1
  },

  ##############################################################################
  ### General
  ##############################################################################

  code => {
    data_type   => 'char',
    size        => 8,
    is_nullable => 0
  },

  title => {
    data_type   => 'varchar',
    size        => 64,
    is_nullable => 1
  },

  type => {
    data_type   => 'integer',
    is_nullable => 0
  },

  expires_in => {
    data_type   => 'integer',
    is_nullable => 0,
  },

  is_reusable => {
    data_type     => 'bit',
    set_on_create => 1,
    default_value => 0,
  },

  ##############################################################################
  ### Other Internals
  ##############################################################################

  is_expired => {
    data_type     => 'bit',
    set_on_create => 1,
    default_value => 0
  },

  created_by => {
    data_type   => 'integer',
    is_nullable => 0,
  },

  created_at => {
    data_type     => 'timestamptz',
    timezone      => 'UTC',
    set_on_create => 1,
    default_value => \'CURRENT_TIMESTAMP'
  },
);

################################################################################

__PACKAGE__->set_primary_key('uid');

__PACKAGE__->belongs_to(
  u => 'CtrlNest::Schema::Result::User',
  { 'foreign.uid' => 'self.created_by' },
  {
    on_delete => 'CASCADE',
    on_update => 'CASCADE',
  }
);

__PACKAGE__->add_unique_constraint([qw( code )]);

################################################################################

1;
