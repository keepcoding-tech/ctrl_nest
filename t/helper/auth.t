use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Bytes::Random::Secure qw(random_string_from);
use Crypt::Bcrypt         qw(bcrypt bcrypt_check);
use Crypt::URandom        qw(urandom);

use CtrlNest::Helper::Auth;
use CtrlNest::Helper::Constants;

use lib 't';
use util::common;
use util::init;

# Init Mojo & Schema
my ($t, $db) = init_tests();

################################################################################

subtest 'Test helper method validate_auth() with random data' => sub {
  for (1 .. 4) {

    # Create a random valid username
    my $username = generate_random_username(
      $_ % 2 == 0 ? USERNAME_MIN_LEN : USERNAME_MAX_LEN);

    # Create a random valid password
    my $password = generate_random_password(
      $_ % 2 == 0 ? PASSWORD_MIN_LEN : PASSWORD_MAX_LEN);

    # Create a random user
    my $user = create_user($db, $username, $password);
    ok(defined $user);

    # The password must mach
    $user = validate_auth($t->app, $username, $password);

    # The user must be returned
    ok(defined $user);
    ok(defined $user->{username});
    ok(defined $user->{password});
    ok(defined $user->{role});

    # Verify username
    ok($user->{username} eq $username);

    # The password most not mach if at least one char si different
    $user = validate_auth($t->app, $username, $password . 'X');
    is($user, undef);

    $user = validate_auth($t->app, $username . 'X', $password);
    is($user, undef);
  }
};

################################################################################

subtest 'Test helper method validate_credentials() with edge cases' => sub {

  # Define the passwords
  my $valid_pass = 'Example123!';
  my $salt       = random_string_from('A-Za-z0-9', 16);

  # Hash the password
  my $valid_hash = bcrypt($valid_pass, PASSWORD_SUBTYPE, PASSWORD_COST, $salt);

  # The password must be defined
  ok(!validate_credentials(undef,       $valid_hash));
  ok(!validate_credentials($valid_pass, undef));

  # The password must exist
  ok(!validate_credentials('',          $valid_hash));
  ok(!validate_credentials($valid_pass, ''));
};


################################################################################

subtest 'Test helper method validate_password()' => sub {

  # Must be defined
  is(validate_password(undef), INVALID);

  # Must contain characters
  is(validate_password(''),    INVALID);
  is(validate_password('   '), INVALID);

  # Must not contain null bytes
  is(validate_password("null\0byte"), INVALID);

  # Must be at least 8 characters
  is(validate_password('Short1!'), INVALID);

  # Must be smaller than 72 characters
  is(
    validate_password(
      'paswoooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooord1!'
    ),
    INVALID
  );

  # Must contain at least one lowercase letter
  is(validate_password('NOLOWERCASE1!'), INVALID);

  # Must contain at least one uppercase letter
  is(validate_password('nouppercase1!'), INVALID);

  # Must contain at least one digit
  is(validate_password('NoDigits!!'), INVALID);

  # Must contain at least one special character
  is(validate_password('NoSpecialChar1'), INVALID);

  # Must contains only these special characters [ ! @ # $ % ^ & * ]
  is(validate_password('InvalidChar<>1A'), INVALID);

  # Contains only valid characters
  is(validate_password('ValidPassword1!'), SUCCESS);
  is(validate_password('Another$Good1'),   SUCCESS);

  # Test with VALID random generated passwords
  for (1 .. 24) {

    # Generate a random password
    my $password = generate_random_password(
      $_ % 2 == 0 ? PASSWORD_MIN_LEN : PASSWORD_MAX_LEN);

    # Validate the password
    is(validate_password($password), SUCCESS);
  }
};


################################################################################

subtest 'Test helper method validate_username()' => sub {

  # Must be defined
  is(validate_username(undef), INVALID);

  # Must contain characters
  is(validate_username(''),    INVALID);
  is(validate_username('   '), INVALID);

  # Must be at least 3 characters
  is(validate_username('us'), INVALID);

  # Must be smaller than 24 characters
  is(validate_username('usernaaaaaaaaaaaaaaaaaame'), INVALID);

  # Must contains only these special characters [ _ . - ]
  is(validate_username('invalid*username'), INVALID);
  is(validate_username('invalid username'), INVALID);

  # Must start with a letter or number
  is(validate_username('.hidden_name'), INVALID);

  # Contains only valid characters
  is(validate_username('valid_user-name.123'), SUCCESS);

  # The username will be trimed
  is(validate_username(' username '), SUCCESS);

  # Allow uppercase letters
  is(validate_username('USER_NAME'), SUCCESS);

  # Test with VALID random generated username
  for (1 .. 24) {

    # Generate a random username
    my $username = generate_random_username(
      $_ % 2 == 0 ? USERNAME_MIN_LEN : USERNAME_MAX_LEN);

    # Validate the username
    is(validate_username($username), SUCCESS);
  }
};

################################################################################

done_testing();
