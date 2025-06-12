package CtrlNest::Schema::ResultSet::AccessCode;

use strict;
use warnings;

use base qw( DBIx::Class::ResultSet );

################################################################################

sub create_new {
  my ($self, $code, $title, $expires_in, $type, $is_reusable, $created_by) = @_;

  # Must be defined
  return undef unless defined $code;
  return undef unless defined $title;
  return undef unless defined $expires_in;
  return undef unless defined $type;
  return undef unless defined $is_reusable;
  return undef unless defined $created_by;

  # Insert a new access code into the database
  my $result_set = $self->create({
    code        => $code,
    title       => $title,
    expires_in  => $expires_in,
    type        => $type,
    is_reusable => $is_reusable,
    created_by  => $created_by
  });

  # The result set must exist
  return undef unless defined $result_set;

  # Return Objects
  return $result_set;
}

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
