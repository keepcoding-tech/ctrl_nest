package CtrlNest::Schema::ResultSet::AccessCode;

use strict;
use warnings;

use base qw( DBIx::Class::ResultSet );

use DateTime;

################################################################################

sub create_new {
  my ($self, $code, $title, $type, $expires_in, $is_reusable, $created_by) = @_;

  # Must be defined
  return undef unless defined $code;
  return undef unless defined $title;
  return undef unless defined $type;
  return undef unless defined $expires_in;
  return undef unless defined $is_reusable;
  return undef unless defined $created_by;

  # Insert a new access code into the database
  my $result_set = $self->create({
    code        => $code,
    title       => $title,
    type        => $type,
    expires_in  => $expires_in,
    is_reusable => $is_reusable,
    created_by  => $created_by
  });

  # The result set must exist
  return undef unless defined $result_set;

  # Return Objects
  return $result_set;
}

################################################################################

sub get_paginated {
  my ($self, $search, $page) = @_;

  # Make the keyword searchable
  my $search_keyword = '%' . $search . '%';

  # Query the database for all access codes
  my $result_set = $self->search(
    [
      {
        code => {
          like => $search_keyword
        }
      },
      {
        title => {
          like => $search_keyword
        }
      }
    ],
    {
      page    => $page,
      join    => 'u',     # alias for 'users'
      columns => [
        'me.code',
        'me.expires_in',
        'me.title',
        'me.type',
        'me.is_expired',
        'me.created_at',
        { username => 'u.username' }    # joined from users
      ],
      order_by => { -desc => 'me.created_at' },
    }
  );

  return $result_set;
}

################################################################################

sub get_by_code {
  my ($self, $code) = @_;

  # Query the database for the access code.
  # Find first result only.
  my $result_set = $self->find({ code => $code });

  # The result set must exist
  return undef unless defined $result_set;

  my %access_code = $result_set->get_columns;

  # Return Object
  return \%access_code;
}

################################################################################

sub get_count {
  my ($self) = @_;

  # Select all the rows of the table and get the count
  my $count = $self->count({});

  # The result set must exist
  return undef unless defined $count;

  # Return Object
  return $count;
}

################################################################################

sub mark_expired {
  my ($self, $uid) = @_;

  # Get the access code object from the database
  my $access_code = $self->find({ uid => $uid });

  # The access code must exist
  return undef unless defined $access_code;

  # Mark the access code as used
  $access_code->update({ is_expired => 1 });

  # Return Object
  return $access_code;
}

################################################################################

1;
