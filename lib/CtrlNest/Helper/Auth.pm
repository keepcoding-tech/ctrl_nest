package CtrlNest::Helper::Auth;
use Mojo::Base -base;

use Crypt::Bcrypt qw(bcrypt bcrypt_check);

use CtrlNest::Helper::Constants;
use CtrlNest::Schema::ResultSet::Users;

use Exporter 'import';
our @EXPORT = qw(
  validate_auth
  validate_credentials
  validate_password
  validate_username
);

################################################################################

# @brief Validates user credentials by checking input constraints and comparing
#   them against the stored (hashed) values in the database.
#
# @param $self     - Mojolicious controller instance.
#        $username - Username received from the client.
#        $password - Password received from the client.
#
# @return
#   - A DBIx::Class::Row object on successful authentication.
#   - undef if validation fails.
#
sub validate_auth {
  my ($self, $username, $password) = @_;

  # Validate username & password
  return undef if validate_username($username) == INVALID;
  return undef if validate_password($password) == INVALID;

  # Get the user object from the database
  my $user = $self->db->resultset('Users')->get_by_username($username);

  # The user must exist
  return undef unless defined $user;

  # Check the password and validate the authentication
  return undef unless validate_credentials($password, $user->{password});

  return $user;    # Success
}

################################################################################

# @brief Validates a plain-text password against its hashed counterpart.
#
# @param $password        - The plain-text password provided by the user.
#        $hashed_password - The stored hashed password to compare against.
#
# @return
#   - 1 if the password matches the hash.
#   - 0 if the password does not match.
#
sub validate_credentials {
  my ($password, $hashed_password) = @_;

  # The passwords must exist
  return INVALID unless defined $password;
  return INVALID unless defined $hashed_password;

  # Use Bcrypt to compare the passwords
  return bcrypt_check($password, $hashed_password);
}

################################################################################

# @brief Validates a password by checking it against defined constraints.
#
# @param $password - The password string to validate.
#
# @return
#   - 1 if the password is valid.
#   - 0 if the password is invalid.
#
sub validate_password {
  my ($password) = @_;

  # Must be defined
  return INVALID unless defined $password;

  # Must not contain null bytes
  return INVALID unless defined $password =~ /\x00/;

  # Minimum and maximum length
  return INVALID if length($password) < PASSWORD_MIN_LEN;
  return INVALID if length($password) > PASSWORD_MAX_LEN;

  # At least one lowercase letter
  return INVALID unless $password =~ /[a-z]/;

  # At least one uppercase letter
  return INVALID unless $password =~ /[A-Z]/;

  # At least one digit
  return INVALID unless $password =~ /\d/;

  # At least one special character [ ! @ # $ % ^ & * ]
  return INVALID unless $password =~ /[!@#\$%\^&\*]/;

  # Allowed characters: letters, numbers and special characters
  return INVALID unless $password =~ /^[a-zA-Z0-9!@#\$%\^&\*]+$/;

  return SUCCESS;
}

################################################################################

# @brief Validates a username by checking it against defined constraints.
#
# @param $username - The username string to validate.
#
# @return
#   - 1 if the username is valid.
#   - 0 if the username is invalid.
#
sub validate_username {
  my ($username) = @_;

  # Must be defined
  return INVALID unless defined $username;

  # Trim whitespace
  $username =~ s/^\s+|\s+$//g;

  # Length constraints
  return INVALID if length($username) < USERNAME_MIN_LEN;
  return INVALID if length($username) > USERNAME_MAX_LEN;

  # Allowed characters: letters, numbers, underscore, hyphen and dot
  return INVALID unless $username =~ /^[a-zA-Z0-9_.-]+$/;

  # Must start with a letter or number
  return INVALID unless $username =~ m{^[a-zA-Z0-9]};

  return SUCCESS;
}

################################################################################

1;
