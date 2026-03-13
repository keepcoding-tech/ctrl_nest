use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Bytes::Random::Secure qw(random_string_from);
use DateTime;
use DateTime::Duration;

use CtrlNest::Helper::AccessCode;
use CtrlNest::Helper::Constants;

use lib 't';
use util::common;
use util::init;

# Init Mojo & Schema
my ($t, $db) = init_tests();

################################################################################

subtest 'Test helper method check_ac_availability()' => sub {

  my $ten_minutes = DateTime::Duration->new(seconds => 600);
  my $one_hour    = DateTime::Duration->new(seconds => 3600);

  # Test with an expired code
  my $created_at = DateTime->now->subtract_duration($one_hour);
  ok(
    check_ac_availability(
      $created_at->strftime("%Y-%m-%d %H:%M:%S%z"),    # (1 hour ago)
      ACCESS_CODE_EXPIRES_IN_30_MIN_SECONDS,
      INVALID,
      INVALID
    ) == INVALID
  );

  # Test with a valid code that is not expired and not reusable
  $created_at = DateTime->now->subtract_duration($ten_minutes);
  ok(
    check_ac_availability(
      $created_at->strftime("%Y-%m-%d %H:%M:%S%z"),    # (10 minutes ago)
      ACCESS_CODE_EXPIRES_IN_30_MIN_SECONDS,
      INVALID,
      INVALID
    ) == SUCCESS
  );

  # Test with a valid code that is not expired but reusable
  ok(
    check_ac_availability(
      $created_at->strftime("%Y-%m-%d %H:%M:%S%z"),    # (10 minutes ago)
      ACCESS_CODE_EXPIRES_IN_30_MIN_SECONDS,
      INVALID,
      SUCCESS
    ) == SUCCESS
  );

  # Test with a code that has never expires and is not reusable
  $created_at = DateTime->now->subtract_duration($one_hour);
  ok(
    check_ac_availability(
      $created_at->strftime("%Y-%m-%d %H:%M:%S%z"),    # (1 hour ago)
      ACCESS_CODE_EXPIRES_IN_NEVER_SECONDS,
      INVALID,
      INVALID
    ) == SUCCESS
  );

  # Test with a code that has never expires and is reusable
  ok(
    check_ac_availability(
      $created_at->strftime("%Y-%m-%d %H:%M:%S"),      # (1 hour ago)
      ACCESS_CODE_EXPIRES_IN_NEVER_SECONDS,
      INVALID,
      SUCCESS
    ) == SUCCESS
  );
};

################################################################################

subtest 'Test helper method generate_ac_unique_code()' => sub {

  # Create a hash with only the allowed characters
  my %allowed = map { $_ => 1 } split //, ACCESS_CODE_ALLOWED_CHARS;

  for (1 .. 24) {

    # Generate the code
    my $unique_code = generate_ac_unique_code();

    # Must be exactly 8 characters
    is(length $unique_code, 8);

    # Must only contain allowed characters
    foreach my $char (split //, $unique_code) {
      ok(exists $allowed{$char});
    }

    # Test multiple generations for uniqueness
    my %seen;
    for (1 .. 1000) {
      ok(!($seen{ generate_ac_unique_code() }++));
    }
  }
};

################################################################################

subtest 'Test helper method process_access_code_db_creation()' => sub {
  for (1 .. 24) {

    # Array with all the expiration durations
    my @expiration_durations = (
      ACCESS_CODE_EXPIRES_IN_10_MIN, ACCESS_CODE_EXPIRES_IN_30_MIN,
      ACCESS_CODE_EXPIRES_IN_60_MIN, ACCESS_CODE_EXPIRES_IN_1_DAY,
      ACCESS_CODE_EXPIRES_IN_7_DAY,  ACCESS_CODE_EXPIRES_IN_30_DAY,
      ACCESS_CODE_EXPIRES_IN_NEVER,
    );

    # Array with all types
    my @types = (
      ACCESS_CODE_TYPE_ALL_RIGHTS, ACCESS_CODE_TYPE_REGISTER,
      ACCESS_CODE_TYPE_2FA,
    );

    # Array with checkboxes values
    my @checkboxes = (CHECKBOX_CHECKED, CHECKBOX_UNCHECKED);

    # Generate the random data for the access code
    my $ac_title       = generate_random_string(int(rand(60)) + 1);
    my $ac_type        = $types[ int(rand(2)) ];
    my $ac_expires_in  = $expiration_durations[ int(rand(6)) ];
    my $ac_is_reusable = $checkboxes[ int(rand(1)) ];

    # Create the admin user with the same username
    my $admin_user = create_admin($db);
    ok(defined $admin_user);

    # Call function to create the access code in the database
    my $access_code = process_access_code_db_creation($t->app, $ac_title,
      $ac_type, $ac_expires_in, $ac_is_reusable, $admin_user->{uid});

    # Must be defined
    ok($access_code != INVALID_PARAMS);

    ok(defined $access_code);

    # Check the access code' data
    ok(defined $access_code->code);
    is($access_code->title,       $ac_title);
    is($access_code->expires_in,  validate_ac_expires_in($ac_expires_in));
    is($access_code->type,        validate_ac_type($ac_type));
    is($access_code->is_reusable, validate_ac_is_reusable($ac_is_reusable));
  }
};

################################################################################

subtest 'Test helper method validate_ac_code()' => sub {

  # Must be defined
  is(validate_ac_code(undef), INVALID);

  # Must contain characters
  is(validate_ac_code(''),    INVALID);
  is(validate_ac_code('   '), INVALID);

  # Only accepts valid characters
  is(validate_ac_code("\0"), INVALID);

  # Must be exactly 8 characters
  is(validate_ac_code('ABCDEFG'),   INVALID);
  is(validate_ac_code('ABCDEFGH2'), INVALID);

  # Must contain only allowed characters
  is(validate_ac_code('ABCD2346'), SUCCESS);
  is(validate_ac_code('abcdefgh'), INVALID); # lowercase letters are not allowed
  is(validate_ac_code('ABCDEFGI'), INVALID); # 'I' is not allowed
  is(validate_ac_code('ABCDEFGO'), INVALID); # 'O' is not allowed
  is(validate_ac_code('ABCDEFGS'), INVALID); # 'S' is not allowed
  is(validate_ac_code('ABCDEFG0'), INVALID); # '0' is not allowed
  is(validate_ac_code('ABCDEFG1'), INVALID); # '1' is not allowed
  is(validate_ac_code('ABCDEFG5'), INVALID); # '5' is not allowed
};

################################################################################

subtest 'Test helper method validate_ac_expires_in()' => sub {

  # Must be defined
  is(validate_ac_expires_in(undef), INVALID);

  # Must contain characters
  is(validate_ac_expires_in(''),    INVALID);
  is(validate_ac_expires_in('   '), INVALID);

  # Only accepts valid characters
  is(validate_ac_expires_in("\0"), INVALID);

  # Non-standard parameters
  is(validate_ac_expires_in('100m'),   INVALID);
  is(validate_ac_expires_in('77d'),    INVALID);
  is(validate_ac_expires_in('1m'),     INVALID);
  is(validate_ac_expires_in('neveer'), INVALID);

  # Success tests
  is(validate_ac_expires_in('10m'),   ACCESS_CODE_EXPIRES_IN_10_MIN_SECONDS);
  is(validate_ac_expires_in('30m'),   ACCESS_CODE_EXPIRES_IN_30_MIN_SECONDS);
  is(validate_ac_expires_in('60m'),   ACCESS_CODE_EXPIRES_IN_60_MIN_SECONDS);
  is(validate_ac_expires_in('1d'),    ACCESS_CODE_EXPIRES_IN_1_DAY_SECONDS);
  is(validate_ac_expires_in('7d'),    ACCESS_CODE_EXPIRES_IN_7_DAY_SECONDS);
  is(validate_ac_expires_in('30d'),   ACCESS_CODE_EXPIRES_IN_30_DAY_SECONDS);
  is(validate_ac_expires_in('never'), ACCESS_CODE_EXPIRES_IN_NEVER_SECONDS);
};

################################################################################

subtest 'Test helper method validate_ac_is_reusable()' => sub {

  # Undefined parameter means that the checkbox was not checked
  is(validate_ac_is_reusable(undef), INVALID_CHECKBOX);

  # Must be the defined constant value
  is(validate_ac_is_reusable(''),                INVALID_CHECKBOX);
  is(validate_ac_is_reusable('   '),             INVALID_CHECKBOX);
  is(validate_ac_is_reusable('on'),              INVALID_CHECKBOX);
  is(validate_ac_is_reusable('off'),             INVALID_CHECKBOX);
  is(validate_ac_is_reusable('is_reusable'),     INVALID_CHECKBOX);
  is(validate_ac_is_reusable('is_not_reusable'), INVALID_CHECKBOX);

  # Success tests (invalid means 0, and success means 1)
  is(validate_ac_is_reusable('unchecked'), INVALID);
  is(validate_ac_is_reusable('checked'),   SUCCESS);
};

################################################################################

subtest 'Test helper method validate_ac_title()' => sub {

  # Must be defined
  is(validate_ac_title(undef), INVALID);

  # Must be at least 1 character
  is(validate_ac_title(''),   INVALID);
  is(validate_ac_title(' '),  INVALID);
  is(validate_ac_title('  '), INVALID);

  # Must be at maximum 60 characters
  is(
    validate_ac_title(
      'ABCDEFGHJKLMNPQRTUVWXYZ2346789ABCDEFGHJKLMNPQRTUVWXYZ2346789A'),
    INVALID
  );

  # Success tests
  is(validate_ac_title('A'),                              SUCCESS);
  is(validate_ac_title('ABCDEFGHJKLMNPQRTUVWXYZ2346789'), SUCCESS);
  is(
    validate_ac_title(
      'ABCDEFGHJKLMNPQRTUVWXYZ2346789ABCDEFGHJKLMNPQRTUVWXYZ2346789'),
    SUCCESS
  );
};

################################################################################

subtest 'Test helper method validate_ac_type()' => sub {

  # Must be defined
  is(validate_ac_type(undef), INVALID);

  # Must contain characters
  is(validate_ac_type(''),    INVALID);
  is(validate_ac_type('   '), INVALID);

  # Only accepts valid characters
  is(validate_ac_type("\0"), INVALID);

  # Non-standard parameters
  is(validate_ac_type('registerr'),   INVALID);
  is(validate_ac_type('2af'),         INVALID);
  is(validate_ac_type('all__rights'), INVALID);

  # Success tests
  is(validate_ac_type('all_rights'), ACCESS_CODE_TYPE_ALL_RIGHTS_BITMASK);
  is(validate_ac_type('register'),   ACCESS_CODE_TYPE_REGISTER_BITMASK);
  is(validate_ac_type('2fa'),        ACCESS_CODE_TYPE_2FA_BITMASK);
};

################################################################################

subtest 'Test helper method validate_access_code()' => sub {

  # Create data for testing
  my $user = create_user($db);
  my $access_code
    = create_access_code($db, undef, undef, undef, undef, undef, undef,
    $user->{uid});

  # Must be defined
  is(validate_access_code(undef,        undef),                     INVALID);
  is(validate_access_code($access_code, undef),                     INVALID);
  is(validate_access_code(undef,        ACCESS_CODE_TYPE_REGISTER), INVALID);

  # We only test the required type of the access code. The availability is
  # tested in the helper method check_ac_availability()

  my $ac_all_rights
    = create_access_code($db, undef, undef, ACCESS_CODE_TYPE_ALL_RIGHTS_BITMASK,
    undef, undef, undef, $user->{uid});
  is(validate_access_code($ac_all_rights, ACCESS_CODE_TYPE_ALL_RIGHTS_BITMASK),
    SUCCESS);

  my $ac_register
    = create_access_code($db, undef, undef, ACCESS_CODE_TYPE_REGISTER_BITMASK,
    undef, undef, undef, $user->{uid});
  is(validate_access_code($ac_register, ACCESS_CODE_TYPE_REGISTER_BITMASK),
    SUCCESS);

  my $ac_2fa
    = create_access_code($db, undef, undef, ACCESS_CODE_TYPE_2FA_BITMASK,
    undef, undef, undef, $user->{uid});
  is(validate_access_code($ac_2fa, ACCESS_CODE_TYPE_2FA_BITMASK), SUCCESS);
};

################################################################################

done_testing();
