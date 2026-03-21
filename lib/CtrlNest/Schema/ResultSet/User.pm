package CtrlNest::Schema::ResultSet::User;

use strict;
use warnings;

use base qw( DBIx::Class::ResultSet );

use Crypt::Bcrypt  qw(bcrypt);
use Crypt::URandom qw(urandom);

use CtrlNest::Helper::Constants;

################################################################################

sub get_by_email {
  my ($self, $email) = @_;

  # Query the database for the username
  # Find first result only
  my $result_set = $self->find({ email => $email });

  # The result set must exist
  return undef unless defined $result_set;

  # Get the row with all the columns
  my %user = $result_set->get_columns;

  # Return Object
  return \%user;
}

################################################################################

sub create_new_user {
  my ($self, $first_name, $last_name, $username, $email, $password) = @_;

  return undef unless defined $first_name;
  return undef unless defined $last_name;
  return undef unless defined $username;
  return undef unless defined $email;
  return undef unless defined $password;

  my $salt = urandom(USER_PASSWORD_SALT_LEN);
  my $hashed
    = bcrypt($password, USER_PASSWORD_SUBTYPE, USER_PASSWORD_COST, $salt);

  # Insert a new user
  my $result_set = $self->create({
    first_name => $first_name,
    last_name  => $last_name,
    username   => $username,
    email      => $email,
    password   => $hashed,
    role       => USER_ROLE_USER,    # Default role is "user"
  });

  # Get the row with all the columns
  my %user = $result_set->get_columns;

  # Return Object
  return \%user;
}

################################################################################

sub get_paginated {
  my ($self, $search, $page) = @_;

  # Make the keyword searchable
  my $search_keyword = '%' . $search . '%';

  # Query the database for 'x' page of users
  my $result_set = $self->search(
    [
      {
        first_name => {
          like => $search_keyword
        },
      },
      {
        last_name => {
          like => $search_keyword
        },
      },
      {
        username => {
          like => $search_keyword
        },
      },
      {
        email => {
          like => $search_keyword
        },
      },
    ],
    {
      page     => $page,
      order_by => { -desc => 'me.created_at' },
      columns  => [qw/first_name last_name username email role created_at/],
    }
  );

  # The result set must exist
  return undef unless $result_set;

  # Return Objects
  return $result_set;
}

################################################################################

sub get_by_username {
  my ($self, $username) = @_;

  # Query the database for the username
  # Find first result only
  my $result_set = $self->find({ username => $username });

  # The result set must exist
  return undef unless defined $result_set;

  # Get the row with all the columns
  my %user = $result_set->get_columns;

  # Return Object
  return \%user;
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

1;
