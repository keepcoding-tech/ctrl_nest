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

  # Max allowed length for email per RFC 5321:
  # 64 (local part) + 1 (@) + 255 (domain)
  email => {
    data_type   => 'varchar',
    size        => 320,
    is_nullable => 0,
  },

  first_name => {
    data_type   => 'varchar',
    size        => 50,
    is_nullable => 0,
  },

  middle_name => {
    data_type   => 'varchar',
    size        => 50,
    is_nullable => 1,
  },

  last_name => {
    data_type   => 'varchar',
    size        => 50,
    is_nullable => 0,
  },

  username => {
    data_type   => 'varchar',
    size        => 24,
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
__PACKAGE__->add_unique_constraint([qw( email username )]);

__PACKAGE__->resultset_class('CtrlNest::Schema::ResultSet::Users');

1;
