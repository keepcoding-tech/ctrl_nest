package CtrlNest::Schema::ResultSet::AccessCode;

use strict;
use warnings;

use base qw( DBIx::Class::ResultSet );

################################################################################

sub get_all {
  my ($self) = @_;

  # Query the database for access codes.
  # Return every result found.
  my @result_set = $self->search(
    undef,
    {
      order_by => { -desc => [qw/created_at/] }
    }
  );

  # The result set must exist
  return undef unless @result_set;

  # Return Objects
  return @result_set;
}

################################################################################

sub get_by_code {
  my ($self, $code) = @_;

  # Query the database for the access code.
  # Find first result only.
  my $result_set = $self->find({ code => $code });

  # The result set must exist
  return undef unless defined $result_set;

  # Return Object
  return $result_set;
}

################################################################################

1;
