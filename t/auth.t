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

subtest 'Validate incorrect password - POST auth() controller method' => sub {
  ok(1 == 1);
};

################################################################################

subtest 'Validate incorrect username - POST auth() controller method' => sub {
  ok(1 == 1);
};

################################################################################

subtest 'Validate correct credentials - POST auth() controller method' => sub {
  ok(1 == 1);
};

################################################################################

subtest 'Validate - GET loockscreen() controller method' => sub {
  ok(1 == 1);
};

################################################################################

subtest 'Validate - GET login() controller method' => sub {
  ok(1 == 1);
};

################################################################################

subtest 'Validate - GET logout() controller method' => sub {

  # Logout user without starting a session
  $t->post_ok('/logout')->status_is(302)->header_is('Location' => '/login');

  # Login user
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => $valid_password
    }
  )->status_is(302)->header_is('Location' => '/home');

  # Logout user with session
  $t->post_ok('/logout')->status_is(302)->header_is('Location' => '/login');
};

################################################################################

done_testing();
