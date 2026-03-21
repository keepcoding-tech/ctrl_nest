package CtrlNest::Helper::Auth;
use Mojo::Base -base;

use Crypt::Bcrypt qw(bcrypt_check);

use CtrlNest::Helper::Constants;
use CtrlNest::Validator::User;

use Exporter 'import';
our @EXPORT = qw(
  authenticate_user_credentials
  process_user_db_creation
);

################################################################################

# @brief Validates user credentials by checking input constraints and comparing
#        them against the stored (hashed) values in the database.
#
# @param $self     - Mojolicious controller instance.
#        $username - Username received from the client.
#        $password - Password received from the client.
#
# @return
#   - A DBIx::Class::Row object on successful authentication.
#   - The appropriate error message if authentication fails.
#
sub authenticate_user_credentials {
  my ($self, $username, $password) = @_;

  # Validate username & password

  my $username_validation = validate_username($username);
  return $username_validation
    unless $username_validation->{status} == SUCCESS;

  my $password_validation = validate_password($password);
  return $password_validation
    unless $password_validation->{status} == SUCCESS;

  # Get the user object from the database
  my $user = $self->db->resultset('User')->get_by_username($username);

  # The user must exist
  unless (defined $user) {
    return {
      status => INVALID,
      error  => 'User not found'
    };
  }

  # Check the password and validate the authentication
  unless (bcrypt_check($password, $user->{password})) {
    return {
      status => INVALID,
      error  => 'Password mismatch'
    };
  }

  return {
    status => SUCCESS,
    data   => $user
  };
}

################################################################################

# @brief Validates user-provided data for account creation and attempts to
#        insert a new user record into the database. Performs checks for input
#        constraints and uniqueness of database constrains.
#
# @param $self       - Mojolicious controller instance.
#        $first_name - The first name provided by the user.
#        $last_name  - The last name provided by the user.
#        $username   - The username provided by the user.
#        $email      - The email provided by the user.
#        $password   - The password provided by the user.
#        $conf_pass  - The confirm password provided by the user.
#
# @return
#   - A DBIx::Class::Row object representing the newly created user on success.
#   - The appropriate error message if the user creation fails.
#
sub process_user_db_creation {
  my ($self, $first_name, $last_name, $username, $email, $password, $conf_pass)
    = @_;

  # Validate parameter data

  my $first_name_validation = validate_first_name($first_name);
  return $first_name_validation
    unless $first_name_validation->{status} == SUCCESS;

  my $last_name_validation = validate_last_name($last_name);
  return $last_name_validation
    unless $last_name_validation->{status} == SUCCESS;

  my $username_validation = validate_username($username);
  return $username_validation
    unless $username_validation->{status} == SUCCESS;

  my $email_address_validation = validate_email($email);
  return $email_address_validation
    unless $email_address_validation->{status} == SUCCESS;

  my $password_validation = validate_password($password);
  return $password_validation
    unless $password_validation->{status} == SUCCESS;

  # The password and confirm password must match
  if ($password ne $conf_pass) {
    return {
      status => INVALID,
      error  => 'Confirmation password does not match'
    };
  }

  # Check if the username or email already exists in the database
  my $existing_user = undef;

  $existing_user = $self->db->resultset('User')->get_by_username($username);
  if (defined $existing_user) {
    return {
      status => INVALID,
      error  => 'Username already in use'
    };
  }

  $existing_user = $self->db->resultset('User')->get_by_email($email);
  if (defined $existing_user) {
    return {
      status => INVALID,
      error  => 'Email already in use'
    };
  }

  # Create the new user
  my $new_user = $self->db->resultset('User')->create_new_user(
    $first_name_validation->{data}, $last_name_validation->{data},
    $username_validation->{data},   $email_address_validation->{data},
    $password_validation->{data}
  );

  unless (defined $new_user) {
    return {
      status => INVALID,
      error  => 'Internal server error'
    };
  }

  return {
    status => SUCCESS,
    data   => $new_user
  };
}

################################################################################

1;
