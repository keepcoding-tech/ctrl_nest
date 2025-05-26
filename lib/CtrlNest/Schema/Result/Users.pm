package CtrlNest::Schema::Result::Users;

use warnings;
use strict;

use base qw( DBIx::Class::Core );

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
    data_type     => 'timestamp',
    set_on_create => 1,
    default_value => \'CURRENT_TIMESTAMP',
  },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw( username )]);

__PACKAGE__->resultset_class('CtrlNest::Schema::ResultSet::Users');

1;
