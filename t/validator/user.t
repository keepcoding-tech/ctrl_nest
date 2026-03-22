use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use CtrlNest::Helper::Constants;
use CtrlNest::Validator::User;

use lib 't';
use util::common;
use util::init;

# Init Mojo & Schema
my ($t, $db) = init_tests();

################################################################################

subtest 'Test validate_email() with edge cases' => sub {

  # Must be defined
  my $email_validation = validate_email(undef);
  is($email_validation->{status}, INVALID);
  is($email_validation->{error},  'Email is required');

  # Must contain characters
  $email_validation = validate_email('');
  is($email_validation->{status}, INVALID);
  is($email_validation->{error},
    'Email must be at least ' . USER_EMAIL_MIN_LEN . ' characters long');

  # Must be smaller than 255 characters
  $email_validation = validate_email('too_long' . ('a' x 240) . '@example.com');
  is($email_validation->{status}, INVALID);
  is($email_validation->{error},
    'Email must be at most ' . USER_EMAIL_MAX_LEN . ' characters long');

  # Use a simple regex to filter obvious invalid emails
  $email_validation = validate_email('invalidemail');
  is($email_validation->{status}, INVALID);
  is($email_validation->{error},  'Email format is invalid');

  $email_validation = validate_email('invalid@');
  is($email_validation->{status}, INVALID);
  is($email_validation->{error},  'Email format is invalid');

  $email_validation = validate_email('@invalid.com');
  is($email_validation->{status}, INVALID);
  is($email_validation->{error},  'Email format is invalid');

  $email_validation = validate_email('invalid@com');
  is($email_validation->{status}, INVALID);
  is($email_validation->{error},  'Email format is invalid');

  $email_validation = validate_email('invalid@.com');
  is($email_validation->{status}, INVALID);
  is($email_validation->{error},  'Email format is invalid');

  $email_validation = validate_email('invalid@com.');
  is($email_validation->{status}, INVALID);
  is($email_validation->{error},  'Email format is invalid');

  $email_validation = validate_email('invalid@com..com');
  is($email_validation->{status}, INVALID);
  is($email_validation->{error},  'Email format is invalid');

  $email_validation = validate_email('invalid@-example.com');
  is($email_validation->{status}, INVALID);
  is($email_validation->{error},  'Email format is invalid');

  $email_validation = validate_email('invalid@example-.com');
  is($email_validation->{status}, INVALID);
  is($email_validation->{error},  'Email format is invalid');

  # Contains only valid characters
  $email_validation = validate_email('valid@email.com');
  is($email_validation->{status}, SUCCESS);
  is($email_validation->{data},   'valid@email.com');

  $email_validation = validate_email(' valid@email.com ');
  is($email_validation->{status}, SUCCESS);
  is($email_validation->{data},   'valid@email.com');
};

################################################################################

subtest 'Test validate_first_name() with edge cases' => sub {

  # Must be defined
  my $first_name_validation = validate_first_name(undef);
  is($first_name_validation->{status}, INVALID);
  is($first_name_validation->{error},  'First name is required');

  # Must contain characters
  $first_name_validation = validate_first_name('');
  is($first_name_validation->{status}, INVALID);
  is($first_name_validation->{error},
        'First name must be at least '
      . USER_FIRST_NAME_MIN_LEN
      . ' characters long');

  # Must be smaller than 65 characters
  $first_name_validation = validate_first_name('John' . ('n' x 65));
  is($first_name_validation->{status}, INVALID);
  is($first_name_validation->{error},
        'First name must be at most '
      . USER_FIRST_NAME_MAX_LEN
      . ' characters long');

  # Must contain only valid characters
  $first_name_validation = validate_first_name('John2000');
  is($first_name_validation->{status}, INVALID);
  is($first_name_validation->{error},  'First name can only contain letters');

  $first_name_validation = validate_first_name('@John');
  is($first_name_validation->{status}, INVALID);
  is($first_name_validation->{error},  'First name can only contain letters');

  $first_name_validation = validate_first_name('John Johnson');
  is($first_name_validation->{status}, INVALID);
  is($first_name_validation->{error},  'First name can only contain letters');

  # Contains only valid characters
  $first_name_validation = validate_first_name('John');
  is($first_name_validation->{status}, SUCCESS);
  is($first_name_validation->{data},   'John');

  $first_name_validation = validate_first_name(' John ');
  is($first_name_validation->{status}, SUCCESS);
  is($first_name_validation->{data},   'John');
};

################################################################################

subtest 'Test validate_last_name() with edge cases' => sub {

  # Must be defined
  my $last_name_validation = validate_last_name(undef);
  is($last_name_validation->{status}, INVALID);
  is($last_name_validation->{error},  'Last name is required');

  # Must contain characters
  $last_name_validation = validate_last_name('');
  is($last_name_validation->{status}, INVALID);
  is($last_name_validation->{error},
        'Last name must be at least '
      . USER_LAST_NAME_MIN_LEN
      . ' characters long');

  $last_name_validation = validate_last_name('Doe ' . ('D' x 65));
  is($last_name_validation->{status}, INVALID);
  is($last_name_validation->{error},
    'Last name must be at most ' . USER_LAST_NAME_MAX_LEN . ' characters long');

  # Must contain only valid characters
  $last_name_validation = validate_last_name('Doe2000');
  is($last_name_validation->{status}, INVALID);
  is($last_name_validation->{error},
    'Last name can only contain letters, spaces and hyphens (-)');

  $last_name_validation = validate_last_name('@Doe');
  is($last_name_validation->{status}, INVALID);
  is($last_name_validation->{error},
    'Last name can only contain letters, spaces and hyphens (-)');

  # Contains only valid characters
  $last_name_validation = validate_last_name('Doe ');
  is($last_name_validation->{status}, SUCCESS);
  is($last_name_validation->{data},   'Doe');

  $last_name_validation = validate_last_name(' Doe Doe');
  is($last_name_validation->{status}, SUCCESS);
  is($last_name_validation->{data},   'Doe Doe');

  $last_name_validation = validate_last_name(' Doe-Doe ');
  is($last_name_validation->{status}, SUCCESS);
  is($last_name_validation->{data},   'Doe-Doe');

};

################################################################################

subtest 'Test validate_password() with edge cases' => sub {

  # Must be defined
  my $password_validation = validate_password(undef);
  is($password_validation->{status}, INVALID);
  is($password_validation->{error},  'Password is required');

  # Must not contain null bytes
  $password_validation = validate_password("null\0byte");
  is($password_validation->{status}, INVALID);
  is($password_validation->{error},  'Password cannot contain null bytes');

  # Must be at least 8 characters
  $password_validation = validate_password('');
  is($password_validation->{status}, INVALID);
  is($password_validation->{error},
    'Password must be at least ' . USER_PASSWORD_MIN_LEN . ' characters long');

  $password_validation = validate_password('   ');
  is($password_validation->{status}, INVALID);
  is($password_validation->{error},
    'Password must be at least ' . USER_PASSWORD_MIN_LEN . ' characters long');

  $password_validation = validate_password('Short1!');
  is($password_validation->{status}, INVALID);
  is($password_validation->{error},
    'Password must be at least ' . USER_PASSWORD_MIN_LEN . ' characters long');

  # Must be smaller than 72 characters
  $password_validation = validate_password('paswo' . ('o' x 66) . 'rd');
  is($password_validation->{status}, INVALID);
  is($password_validation->{error},
    'Password must be at most ' . USER_PASSWORD_MAX_LEN . ' characters long');

  # Must contain at least one lowercase letter
  $password_validation = validate_password('NOLOWERCASE1!');
  is($password_validation->{status}, INVALID);
  is($password_validation->{error},
    'Password must contain at least one lowercase letter');

  # Must contain at least one uppercase letter
  $password_validation = validate_password('nouppercase1!');
  is($password_validation->{status}, INVALID);
  is($password_validation->{error},
    'Password must contain at least one uppercase letter');

  # Must contain at least one digit
  $password_validation = validate_password('NoDigits!!');
  is($password_validation->{status}, INVALID);
  is($password_validation->{error}, 'Password must contain at least one digit');

  # Must contain at least one special character
  $password_validation = validate_password('NoSpecialChar1');
  is($password_validation->{status}, INVALID);
  is($password_validation->{error},
        'Password must contain at least one '
      . 'special character [ ! @ # $ % ^ & * - ]');

  # Must contains only these special characters [ ! @ # $ % ^ & * - ]
  $password_validation = validate_password('Inv@lidChar<>1A');
  is($password_validation->{status}, INVALID);
  is($password_validation->{error},
        'Password can only contain letters, numbers and these special '
      . 'characters: [ ! @ # $ % ^ & * - ]');

  # Contains only valid characters
  $password_validation = validate_password(' ValidPassword1!');
  is($password_validation->{status}, SUCCESS);
  is($password_validation->{data},   'ValidPassword1!');

  $password_validation = validate_password('Another$Good1 ');
  is($password_validation->{status}, SUCCESS);
  is($password_validation->{data},   'Another$Good1');

  # Test with VALID random generated passwords
  for (1 .. 24) {

    # Generate a random password
    my $password = generate_random_password(
      $_ % 2 == 0 ? USER_PASSWORD_MIN_LEN : USER_PASSWORD_MAX_LEN);

    # Validate the password
    $password_validation = validate_password($password);
    is($password_validation->{status}, SUCCESS);
    is($password_validation->{data},   $password);
  }
};


################################################################################

subtest 'Test validate_username() with edge cases' => sub {

  # Must be defined
  my $username_validation = validate_username(undef);
  is($username_validation->{status}, INVALID);
  is($username_validation->{error},  'Username is required');

  # Must be at least 3 characters
  $username_validation = validate_username('');
  is($username_validation->{status}, INVALID);
  is($username_validation->{error},
    'Username must be at least ' . USER_USERNAME_MIN_LEN . ' characters long');

  $username_validation = validate_username('   ');
  is($username_validation->{status}, INVALID);
  is($username_validation->{error},
    'Username must be at least ' . USER_USERNAME_MIN_LEN . ' characters long');

  $username_validation = validate_username('us');
  is($username_validation->{status}, INVALID);
  is($username_validation->{error},
    'Username must be at least ' . USER_USERNAME_MIN_LEN . ' characters long');

  # Must be smaller than 64 characters
  $username_validation = validate_username('usern' . ('a' x 58) . 'me');
  is($username_validation->{status}, INVALID);
  is($username_validation->{error},
    'Username must be at most ' . USER_USERNAME_MAX_LEN . ' characters long');

  # Must contain only these special characters [ _ - ]
  $username_validation = validate_username('invalid*username');
  is($username_validation->{status}, INVALID);
  is($username_validation->{error},
        'Username can only contain letters, numbers, '
      . 'underscores (_) and hyphens (-)');

  $username_validation = validate_username('invalid username');
  is($username_validation->{status}, INVALID);
  is($username_validation->{error},
        'Username can only contain letters, numbers, '
      . 'underscores (_) and hyphens (-)');

  # Must start with a letter or number
  $username_validation = validate_username('-hidden_name');
  is($username_validation->{status}, INVALID);
  is($username_validation->{error},
    'Username must start with a letter or number');

  # Contains only valid characters
  $username_validation = validate_username('valid_user-name123');
  is($username_validation->{status}, SUCCESS);
  is($username_validation->{data},   'valid_user-name123');

  # The username will be trimed
  $username_validation = validate_username(' username ');
  is($username_validation->{status}, SUCCESS);
  is($username_validation->{data},   'username');

  # Allow uppercase letters
  $username_validation = validate_username('USER_NAME');
  is($username_validation->{status}, SUCCESS);
  is($username_validation->{data},   'USER_NAME');

  # Test with VALID random generated username
  for (1 .. 24) {

    # Generate a random username
    my $username = generate_random_username(
      $_ % 2 == 0 ? USER_USERNAME_MIN_LEN : USER_USERNAME_MAX_LEN);

    # Validate the username
    $username_validation = validate_username($username);
    is($username_validation->{status}, SUCCESS);
    is($username_validation->{data},   $username);
  }
};

################################################################################

done_testing();
