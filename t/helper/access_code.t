use Mojo::Base -strict;

use DateTime;
use Test::More;
use Test::Mojo;

use CtrlNest::Helper::AccessCode;
use CtrlNest::Helper::Constants;

use lib 't';
use util::common;
use util::init;

# Init Mojo & Schema
my ($t, $db) = init_tests();

################################################################################

subtest 'Test helper method check_access_code_integrity()' => sub {

  # Must be defined
  is(check_access_code_integrity(undef), INVALID);

  # Must contain characters
  is(check_access_code_integrity(''),    INVALID);
  is(check_access_code_integrity('   '), INVALID);

  # Must not contain null bytes
  is(check_access_code_integrity("ABC\0DEFG"), INVALID);

  # Must be exactly 8 characters
  is(check_access_code_integrity('ABC'),       INVALID);
  is(check_access_code_integrity('ABCDEFGHJ'), INVALID);

  # Must contains only these characters [ ABCDEFGHJKLMNPQRTUVWXYZ2346789 ]
  is(check_access_code_integrity('O0I1S5'),   INVALID);
  is(check_access_code_integrity('!@#$%^&*'), INVALID);

  # Contains only valid characters
  is(check_access_code_integrity('ABCDEFGH'), SUCCESS);
  is(check_access_code_integrity('A2346789'), SUCCESS);

  # Test with VALID random generated access codes
  for (1 .. 24) {

    # Generate a random access code
    my $access_code = generate_random_access_code();

    # Validate the access code
    is(check_access_code_integrity($access_code), SUCCESS);
  }
};

################################################################################

subtest 'Test helper method check_expiration_date()' => sub {
  for my $i (1 .. 24) {

    # Generate a random offset between -3600 and +3600 seconds
    my $offset = int(rand(7201)) - 3600;

    # Create a DateTime object with the random created offset
    my $dt = DateTime->now(time_zone => 'UTC')->add(seconds => $offset);

    # If the offset is smaller than 0, the access code is expired
    my $expected = $offset < 0 ? INVALID : SUCCESS;

    is(check_expiration_date($dt), $expected);
  }
};

################################################################################

subtest 'Test helper method validate_access_code()' => sub {
  for (1 .. 24) {

    # Generate a random access code
    my $random_access_code = generate_random_access_code();

    # Create a random access code
    my $access_code = create_access_code($db, $random_access_code);
    ok(defined $access_code);

    # The access code must mach
    is(validate_access_code($t->app, $random_access_code), SUCCESS);
  }
};

################################################################################

done_testing();
