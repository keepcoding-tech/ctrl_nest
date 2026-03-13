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

  # Should fail if not logged in
  $t->get_ok('/settings')->status_is(302)->header_is('Location' => '/login');

  # Sign in the user and access page
  signin_user($t, $valid_username, $valid_password);
  $t->get_ok('/settings/access_codes')
    ->status_is(200)
    ->content_like(qr/Access Codes/);

  # Should pass for correct values
  $t->post_ok(
    '/access_code/create' => form => {
      title       => 'Test Access Code',
      expires_in  => ACCESS_CODE_EXPIRES_IN_10_MIN,
      type        => ACCESS_CODE_TYPE_ALL_RIGHTS,
      is_reusable => 'checked'
    }
    )
    ->status_is(302)
    ->follow_redirect()
    ->content_like(qr/Access code created succesfully!/);
  $t->post_ok(
    '/access_code/create' => form => {
      title      => 'Test Access Code',
      expires_in => ACCESS_CODE_EXPIRES_IN_10_MIN,
      type       => ACCESS_CODE_TYPE_ALL_RIGHTS,
    }
    )
    ->status_is(302)
    ->follow_redirect()
    ->content_like(qr/Access code created succesfully!/);
};

################################################################################

subtest 'Validate - GET users() controller method' => sub {

  # Sign out the user to test the redirection
  signout_user($t);

  # Should fail if not logged in
  $t->get_ok('/settings/users')
    ->status_is(302)
    ->header_is('Location' => '/login');

  # Sign in the user
  signin_user($t, $valid_username, $valid_password);

  # Should open the settings page
  $t->get_ok('/settings/users')
    ->status_is(200)
    ->content_like(qr/Settings/)
    ->content_like(qr/Users/);

  # Create 10 test users
  for (1 .. 10) {
    my $user = create_user(
      $db, "Test",
      "User" . "$_",
      "test_user" . "$_",
      "test.user" . "$_" . "\@mail.com"
    );
  }

  # All users should appear in the list
  $t->get_ok('/settings/users')
    ->status_is(200)
    ->content_like(qr/Test User1/)
    ->content_like(qr/Test User2/)
    ->content_like(qr/Test User3/)
    ->content_like(qr/Test User4/)
    ->content_like(qr/Test User5/)
    ->content_like(qr/Test User6/)
    ->content_like(qr/Test User7/)
    ->content_like(qr/Test User8/)
    ->content_like(qr/Test User9/)
    ->content_like(qr/Test User10/);

  # The following test will check the search input

  # Only the searched username should appear in the list
  $t->get_ok('/settings/users?search=test_user8')
    ->status_is(200)
    ->content_unlike(qr/Test User1/)
    ->content_unlike(qr/Test User2/)
    ->content_unlike(qr/Test User3/)
    ->content_unlike(qr/Test User4/)
    ->content_unlike(qr/Test User5/)
    ->content_unlike(qr/Test User6/)
    ->content_unlike(qr/Test User7/)
    ->content_like(qr/Test User8/)
    ->content_unlike(qr/Test User9/)
    ->content_unlike(qr/Test User10/);

  # Only the searched name should appear in the list
  $t->get_ok('/settings/users?search=User8')
    ->status_is(200)
    ->content_unlike(qr/Test User1/)
    ->content_unlike(qr/Test User2/)
    ->content_unlike(qr/Test User3/)
    ->content_unlike(qr/Test User4/)
    ->content_unlike(qr/Test User5/)
    ->content_unlike(qr/Test User6/)
    ->content_unlike(qr/Test User7/)
    ->content_like(qr/Test User8/)
    ->content_unlike(qr/Test User9/)
    ->content_unlike(qr/Test User10/);

  # Only the searched email should appear in the list
  $t->get_ok('/settings/users?search=test.user8')
    ->status_is(200)
    ->content_unlike(qr/Test User1/)
    ->content_unlike(qr/Test User2/)
    ->content_unlike(qr/Test User3/)
    ->content_unlike(qr/Test User4/)
    ->content_unlike(qr/Test User5/)
    ->content_unlike(qr/Test User6/)
    ->content_unlike(qr/Test User7/)
    ->content_like(qr/Test User8/)
    ->content_unlike(qr/Test User9/)
    ->content_unlike(qr/Test User10/);

  # The following tests will check the pagination

  # Create another 20 test users (3 pages in total)
  for (11 .. 30) {
    my $user = create_user(
      $db, "Test",
      "User" . "$_",
      "test_user" . "$_",
      "test.user" . "$_" . "\@mail.com"
    );
  }

  # Only the first 10 entries should appear
  $t->get_ok('/settings/users?page=1')
    ->status_is(200)
    ->content_like(qr/Test User30/)
    ->content_like(qr/Test User29/)
    ->content_like(qr/Test User28/)
    ->content_like(qr/Test User27/)
    ->content_like(qr/Test User26/)
    ->content_like(qr/Test User25/)
    ->content_like(qr/Test User24/)
    ->content_like(qr/Test User23/)
    ->content_like(qr/Test User22/)
    ->content_like(qr/Test User21/)
    ->content_unlike(qr/Test User20/);

  # Only the second page should appear
  $t->get_ok('/settings/users?page=2')
    ->status_is(200)
    ->content_like(qr/Test User20/)
    ->content_like(qr/Test User19/)
    ->content_like(qr/Test User18/)
    ->content_like(qr/Test User17/)
    ->content_like(qr/Test User16/)
    ->content_like(qr/Test User15/)
    ->content_like(qr/Test User14/)
    ->content_like(qr/Test User13/)
    ->content_like(qr/Test User12/)
    ->content_like(qr/Test User11/)
    ->content_unlike(qr/Test User10/);

  # Only the third page should appear
  $t->get_ok('/settings/users?page=3')
    ->status_is(200)
    ->content_like(qr/Test User10/)
    ->content_like(qr/Test User9/)
    ->content_like(qr/Test User8/)
    ->content_like(qr/Test User7/)
    ->content_like(qr/Test User6/)
    ->content_like(qr/Test User5/)
    ->content_like(qr/Test User4/)
    ->content_like(qr/Test User3/)
    ->content_like(qr/Test User2/)
    ->content_like(qr/Test User1/);
};

################################################################################

done_testing();
