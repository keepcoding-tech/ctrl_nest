use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Bytes::Random::Secure qw(random_string_from);

use CtrlNest::Helper::AccessCode;
use CtrlNest::Helper::Constants;

use lib 't';
use util::common;
use util::init;

# Init Mojo & Schema
my ($t, $db) = init_tests();

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
    my $ac_expires_in  = $expiration_durations[ int(rand(6)) ];
    my $ac_type        = $types[ int(rand(2)) ];
    my $ac_is_reusable = $checkboxes[ int(rand(1)) ];
    my $ac_created_by  = generate_random_username();

    # Create the admin user with the same username
    ok(defined create_admin($db, $ac_created_by));

    # Call function to create the access code in the database
    my $access_code = process_access_code_db_creation($t->app, $ac_title,
      $ac_expires_in, $ac_type, $ac_is_reusable, $ac_created_by);

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

done_testing();
