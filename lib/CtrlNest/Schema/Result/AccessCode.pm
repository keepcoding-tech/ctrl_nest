package CtrlNest::Schema::Result::AccessCode;

use warnings;
use strict;

use DateTime;
use DateTime::Duration;

use base qw( DBIx::Class::Core );

# Convert timestamps to DateTime objects
__PACKAGE__->load_components(qw/InflateColumn::DateTime/);

# Creates the table
__PACKAGE__->table('access_code');

# Add all the table' columns
__PACKAGE__->add_columns(
  id => {
    data_type         => 'integer',
    is_auto_increment => 1
  },

  code => {
    data_type   => 'char',
    size        => 8,
    is_nullable => 0
  },

  code_name => {
    data_type   => 'varchar',
    size        => 60,
    is_nullable => 1
  },

  expires_in => {
    data_type   => 'integer',
    is_nullable => 0,
  },

  is_expired => {
    data_type     => 'bit',
    set_on_create => 1,
    default_value => 0
  },

  created_at => {
    data_type     => 'timestamptz',
    timezone      => 'UTC',
    set_on_create => 1,
    default_value => \'CURRENT_TIMESTAMP'
  },
);

# Add primary key constraint
__PACKAGE__->set_primary_key('id');

# Add unique constraints
__PACKAGE__->add_unique_constraint([qw( code )]);

# Link this Result to it's ResultSet
__PACKAGE__->resultset_class('CtrlNest::Schema::ResultSet::AccessCode');

################################################################################


# sub expires_in {
#   my $self = shift;

#   my $expires_at = $self->expires_at;
#   my $now        = DateTime->now(time_zone => 'UTC');

#   my $remaining
#     = $expires_at > $now
#     ? $expires_at->subtract_datetime($now)
#     : DateTime::Duration->new;

#   my $d = $remaining->in_units('days');
#   my $h = $remaining->in_units('hours') % 24;
#   my $m = $remaining->in_units('minutes') % 60;

#   my @parts;
#   push @parts, "${d}d" if $d > 0;
#   push @parts, "${h}h" if $d > 0 || $h > 0;
#   push @parts, "${m}m";

#   return join ', ', @parts;
# }

################################################################################

1;

