package util::common;

use strict;
use warnings;

use Test::More;
use Test::Mojo;

use Bytes::Random::Secure qw(random_string_from);
use Crypt::Bcrypt         qw(bcrypt bcrypt_check);
use Crypt::URandom        qw(urandom);
use List::Util            qw(shuffle);

use CtrlNest::Helper::Constants;

use Exporter 'import';
our @EXPORT = qw(
  create_admin
  create_sudo
  create_user
  generate_random_password
  generate_random_string
  generate_random_username
  signin_user
  signout_user
);

################################################################################

# @brief Creates a admin user in the database with the provided data.
#
# @return
#   - A DBIx::Class::Result object if insertion succeeds.
#   - undef on failure.
#
sub create_admin {
  my ($db, $username, $password) = @_;

  # Asign default values for admin user
  $username //= 'admin';
  $password //= 'P@ssw0rd';

  # Create the admin user
  return create_user($db, $username, $password, ROLE_ADMIN);
}

################################################################################

# @brief Creates a sudo user in the database with the provided data.
#
# @return
#   - A DBIx::Class::Result object if insertion succeeds.
#   - undef on failure.
#
sub create_sudo {
  my ($db, $username, $password) = @_;

  # Asign default values for sudo user
  $username //= 'sudo';
  $password //= 'P@ssw0rd';

  # Create the sudo user
  return create_user($db, $username, $password, ROLE_SUDO);
}

################################################################################

# @brief Creates a user in the database with the provided data.
#
# @param $username - The username provided by the client.
#        $password - The corresponding password.
#        $role     - User role: 'sudo', 'admin', or 'user'.
#
# @return
#   - A DBIx::Class::Result object if insertion succeeds.
#   - undef on failure.
#
sub create_user {
  my ($db, $username, $password, $role) = @_;

  # Asign default values if not provided
  $username //= 'test_user';
  $password //= 'P@ssw0rd';
  $role     //= ROLE_USER;

  # Create a hashed password
  my $salt   = urandom(PASSWORD_SALT_LEN);
  my $hashed = bcrypt($password, PASSWORD_SUBTYPE, PASSWORD_COST, $salt);

  # Insert the new user
  my $result_set = $db->resultset('Users')->create({
    username => $username,
    password => $hashed,
    role     => $role
  });

  # Validate insertion
  return undef unless defined $result_set;

  # Return the newly create user
  my %user = $result_set->get_columns;

  return \%user;
}

################################################################################

# @brief Generates a valid random password.
#
# @param $len - The exact length of the password.
#
# @return
#   - A string representing the generated password.
#
sub generate_random_password {
  my ($len) = @_;

  # Asign a random length if not provided
  $len //= int(rand(PASSWORD_MAX_LEN)) + PASSWORD_MIN_LEN;

  # Adjust lengths to ensure total length is $len
  my $part_len  = int($len / 4);
  my $remainder = $len - 3 * $part_len;    # ensures exact length

  my $password = '';

  # Add lowercase letters
  $password .= random_string_from('abcdefghijklmnopqrstuvwxyz', $part_len);

  # Add uppercase letters
  $password .= random_string_from('ABCDEFGHIJKLMNOPQRSTUVQXYZ', $part_len);

  # Add digits
  $password .= random_string_from('0123456789', $part_len);

  # Add special characters
  $password .= random_string_from('!@#$%^&*', $remainder);

  # Shuffle the characters
  return join '', shuffle split //, $password;
}

################################################################################

# @brief Generates a random alphanumeric string.
#
# @param $len - The exact length of the string.
#
# @return
#   - The generated alphanumeric string.
#
sub generate_random_string {
  my ($len) = @_;

  # Generate a random alphanumeric string
  return random_string_from(
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVQXYZ0123456789', $len);
}

################################################################################

# @brief Generates a valid random username.
#
# @param $len - The exact length of the username.
#
# @return
#   - A string representing the generated username.
#
sub generate_random_username {
  my ($len) = @_;

  # Asign a random length if not provided
  $len //= int(rand(USERNAME_MAX_LEN)) + USERNAME_MIN_LEN;

  # First character must be letter or number
  my $username_part_1 = random_string_from(
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVQXYZ0123456789', 1);

  # Allowed characters: letters, numbers, underscore, hyphen and dot
  my $username_part_2
    = random_string_from(
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVQXYZ0123456789_.-',
    $len - 1);

  # Combine the random generated strings
  my $username = $username_part_1 . $username_part_2;

  # Return the newly generated username
  return $username;
}

################################################################################

# @brief Handles the authentication process for a provided user.
#
# @param $username - The username provided by the client.
#        $password - The corresponding password.
#
# @return
#
sub signin_user {
  my ($t, $username, $password) = @_;

  # Must be defined
  ok(defined $username);
  ok(defined $password);

  # Should be able to access the login page
  $t->get_ok('/login')
    ->status_is(200)
    ->element_exists('form input[name="username"]')
    ->element_exists('form input[name="password"]');

  # Authenticate the user
  $t->post_ok(
    '/auth' => form => {
      username => $username,
      password => $password
    }
  )->status_is(302)->header_is('Location' => '/home');
}

################################################################################

# @brief Handles the logout process for a provided user.
#
# @param
#
# @return
#
sub signout_user {
  my ($t) = @_;

  # Logout user with session
  $t->post_ok('/logout')->status_is(302)->header_is('Location' => '/login');
}

################################################################################

1;
