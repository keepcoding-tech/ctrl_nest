use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Bytes::Random::Secure qw(random_string_from);
use DateTime;
use DateTime::Duration;

use CtrlNest::Helper::AccessCode;
use CtrlNest::Helper::Constants;
use CtrlNest::Validator::AccessCode;

use lib 't';
use util::common;
use util::init;

# Init Mojo & Schema
my ($t, $db) = init_tests();

# Create an admin test user
my $admin_user = create_admin($db);

################################################################################

subtest 'Test check_ac_availability()' => sub {

  # Must be defined
  is(check_ac_availability(undef), INVALID);

  # Test already expired access code
  my $expired_ac
    = create_access_code($db, undef, undef, undef,
    undef, undef, 1, $admin_user->{uid});

  is(check_ac_availability($expired_ac), INVALID);

  # Test access code that never expires
  my $never_expires_ac
    = create_access_code($db, undef, undef, undef,
    ACCESS_CODE_EXPIRES_IN_NEVER, undef, undef, $admin_user->{uid});

  is(check_ac_availability($never_expires_ac), SUCCESS);

  # Test valid access code
  my $valid_ac
    = create_access_code($db, undef, undef, undef,
    undef, undef, undef, $admin_user->{uid});

  is(check_ac_availability($valid_ac), SUCCESS);

  # Test expired access code based on timestamp
  my $invalid_ac
    = create_access_code($db, undef, undef, undef,
    undef, undef, undef, $admin_user->{uid});

  $invalid_ac->update({
    created_at => DateTime->now()->subtract(minutes => 32)
  });

  is(check_ac_availability($invalid_ac), INVALID);
};

################################################################################

subtest 'Test generate_ac_unique_code() with random data' => sub {

  # Create a hash with only the allowed characters
  my %allowed = map { $_ => 1 } split //, 'ABCDEFGHJKLMNPQRTUVWXYZ2346789';

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

subtest 'Test process_access_code_db_creation() with random data' => sub {
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
    ok($access_code->{status} == SUCCESS);

    # Check the access code' data
    ok(defined $access_code->{data});
    is($access_code->{data}->title,      $ac_title);
    is($access_code->{data}->expires_in, $ac_expires_in);
    is($access_code->{data}->type,       $ac_type);
    is($access_code->{data}->is_reusable,
      validate_ac_is_reusable($ac_is_reusable)->{data});
  }
};

################################################################################

subtest 'Test verify_access_code_validity()' => sub {
  my $ac
    = create_access_code($db, undef, undef, ACCESS_CODE_TYPE_REGISTER,
    undef, undef, undef, $admin_user->{uid});

  # Parameters must be defined
  my $access_code = verify_access_code_validity($t->app, undef, undef);
  is($access_code->{status}, INVALID);
  is($access_code->{error},  'Access code is required');

  $access_code = verify_access_code_validity($t->app, $ac->code, undef);
  is($access_code->{status}, INVALID);
  is($access_code->{error},  'Access code type is required');

  # The access code must exist
  $access_code = verify_access_code_validity($t->app,
    generate_ac_unique_code(), ACCESS_CODE_TYPE_REGISTER);
  is($access_code->{status}, INVALID);
  is($access_code->{error},  'Access code not found');

  # The required type must match
  $access_code
    = verify_access_code_validity($t->app, $ac->code, ACCESS_CODE_TYPE_2FA);
  is($access_code->{status}, INVALID);
  is($access_code->{error},  'Access code type mismatch');

  # Should pass if the type is for all rights
  $ac
    = create_access_code($db, undef, undef, ACCESS_CODE_TYPE_ALL_RIGHTS,
    undef, undef, undef, $admin_user->{uid});

  $access_code = verify_access_code_validity($t->app,
    $ac->code, ACCESS_CODE_TYPE_REGISTER);
  is($access_code->{status}, SUCCESS);
};

################################################################################

done_testing();
