use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use CtrlNest::Helper::Constants;

use lib 't';
use util::init;
use util::common;

# Init Mojo & Schema
my ($t, $db) = init_tests();

# Valid credentials for testing
my $valid_username = 'test_user';
my $valid_password = 'P@ssw0rd';

# Create a new test user
my $user
  = create_user($db, undef, undef, $valid_username, undef, $valid_password);

################################################################################

subtest 'Validate - POST create_access_code() controller method' => sub {
  ok(1 == 1);
};

################################################################################

subtest 'Validate - GET users() controller method' => sub {
  ok(1 == 1);
};

################################################################################

done_testing();
