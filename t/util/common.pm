package util::common;

use strict;
use warnings;

use Bytes::Random::Secure qw(random_string_from);
use Crypt::Bcrypt         qw(bcrypt bcrypt_check);
use Crypt::URandom        qw(urandom);
use DateTime              qw(now);
use List::Util            qw(shuffle);

use CtrlNest::Helper::Constants;

use Exporter 'import';
our @EXPORT = qw(
  create_access_code
  create_user
  generate_random_access_code
  generate_random_password
  generate_random_username
);

################################################################################

# @param $code     - The code to be inserted into the database.
#        $duration - The duration after which the code expires.
#
# @return
#   - A DBIx::Class::Result object if insertion succeeds.
#   - undef on failure.
#
sub create_access_code {
  my ($db, $code, $code_name, $duration) = @_;

  # Asign default values if not provided
  $code      //= 'ABCDEFGH';
  $code_name //= 'test_access_code';
  $duration  //= 3600;

  # Create the timestamp
  my $expires_at = DateTime->now->add(seconds => $duration);

  # Insert the new user
  my $result_set = $db->resultset('AccessCode')->create({
    code       => $code,
    code_name  => $code_name,
    expires_at => $expires_at
  });

  # Validate insertion
  return undef unless defined $result_set;

  return $result_set;
}

################################################################################

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
    email       => 'email',
    first_name  => 'test',
    middle_name => undef,
    last_name   => 'user',
    username    => $username,
    password    => $hashed,
    role        => $role
  });

  # Validate insertion
  return undef unless defined $result_set;

  # Return the newly create user
  my %user = $result_set->get_columns;

  return \%user;
}

################################################################################

# @brief Generates a valid random access code.
#
# @param $len - The exact length of the access code.
#
# @return
#   - A string representing the generated access code.
#
sub generate_random_access_code {

  # Generate a random 8 characters access code
  return random_string_from('ABCDEFGHJKLMNPQRTUVWXYZ2346789', ACCESS_CODE_LEN);
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

# @brief Generates a valid random username.
#
# @param $len - The exact length of the username.
#
# @return
#   - A string representing the generated username.
#
sub generate_random_username {
  my ($len) = @_;

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

1;
