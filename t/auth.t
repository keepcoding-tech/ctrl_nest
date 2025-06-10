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
my $user = create_user($db, $valid_username, $valid_password);

# $2b$12$ZKzV6tUcHGqX/.4sK.5wOOYq2M2ioWI/qSYQtTTTCL0.sFzKdaumS

################################################################################

subtest 'Validate incorect - password POST auth() controller method' => sub {

  # Must exists
  $t->post_ok('/auth' => form => { username => $valid_username })
    ->status_is(401)
    ->content_like(qr/Invalid credentials/);

  # Must contain characters
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => ''
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => '  '
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must not contain null bytes
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => "null\0byte"
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must be at least 8 characters
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => "Short1!"
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must be smaller than 72 characters
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password =>
        "paswoooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooord1!"
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must contain at least one lowercase letter
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => "NOLOWERCASE1!"
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must contain at least one uppercase letter
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => "nouppercase1!"
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must contain at least one digit
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => "NoDigits!!"
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must contain at least one special character
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => "NoSpecialChar1"
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must contains only these special characters [ ! @ # $ % ^ & * ]
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => "InvalidChar<>1A"
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must contain at least one digit
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => "NoDigits!!"
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);
};

################################################################################

subtest 'Validate incorect username - POST auth() controller method' => sub {

  # Muse exist
  $t->post_ok('/auth' => form => { password => $valid_password })
    ->status_is(401)
    ->content_like(qr/Invalid credentials/);

  # Must contain characters
  $t->post_ok(
    '/auth' => form => {
      username => '',
      password => $valid_password
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);
  $t->post_ok(
    '/auth' => form => {
      username => '   ',
      password => $valid_password
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must be at least 3 characters
  $t->post_ok(
    '/auth' => form => {
      username => 'us',
      password => $valid_password
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must be smaller than 24 characters
  $t->post_ok(
    '/auth' => form => {
      username => 'usernaaaaaaaaaaaaaaaaaame',
      password => $valid_password
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must contains only these special characters [ _ . - ]
  $t->post_ok(
    '/auth' => form => {
      username => 'invalid*username',
      password => $valid_password
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);
  $t->post_ok(
    '/auth' => form => {
      username => 'invalid username',
      password => $valid_password
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Must start with a letter or number
  $t->post_ok(
    '/auth' => form => {
      username => '.hidden_name',
      password => $valid_password
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Contains only valid characters
  $t->post_ok(
    '/auth' => form => {
      username => 'valid_user',
      password => $valid_password
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);
};

################################################################################

subtest 'Validate corect credentials - POST auth() controller method' => sub {

  # Standard authentication, should redirect to /home
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => $valid_password
    }
  )->status_is(302)->header_is('Location' => '/home');

  # Logout user
  $t->post_ok('/logout')->status_is(302)->header_is('Location' => '/login');

  # Test with VALID random generated passwords
  for (1 .. 4) {

    # Generate a random username
    my $username = generate_random_username(
      $_ % 2 == 0 ? USERNAME_MIN_LEN : USERNAME_MAX_LEN);

    # Generate a random password
    my $password = generate_random_password(
      $_ % 2 == 0 ? PASSWORD_MIN_LEN : PASSWORD_MAX_LEN);

    # Create a new user with the random generated credentials
    my $random_user = create_user($db, $username, $password);
    ok(defined $random_user);

    # Authenticate with the newly generated password
    $t->post_ok(
      '/auth' => form => {
        username => $username,
        password => $password
      }
    )->status_is(302)->header_is('Location' => '/home');

    # Logout user
    $t->post_ok('/logout')->status_is(302)->header_is('Location' => '/login');
  }
};

################################################################################

subtest 'Validate - GET loockscreen() controller method' => sub {

  # Should be able to reach the page
  $t->get_ok('/lockscreen')
    ->status_is(200)
    ->element_exists('form input[name="username"]')
    ->element_exists('form input[name="password"]');

  # The username hidden field should not contain any value
  my $dom = $t->tx->res->dom;
  is($dom->at('input[name="username"]')->attr('value'), SESSION_NOT_FOUND);

  # Can't retrive session without signing-in first
  $t->post_ok(
    '/auth' => form => {
      username => SESSION_NOT_FOUND,
      password => $valid_password
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);

  # Sign in user
  $t->post_ok(
    '/auth' => form => {
      username => $valid_username,
      password => $valid_password
    }
  )->status_is(302)->header_is('Location' => '/home');

  # Should be able to reach the page
  $t->get_ok('/lockscreen')
    ->status_is(200)
    ->element_exists('form input[name="username"]')
    ->element_exists('form input[name="password"]');

  # The username hidden field should not contain any value
  $dom = $t->tx->res->dom;
  is($dom->at('input[name="username"]')->attr('value'), $valid_username);

  # Logout user
  $t->post_ok('/logout')->status_is(302)->header_is('Location' => '/login');
};

################################################################################

subtest 'Validate - GET login() controller method' => sub {

  # Should be able to reach the page
  $t->get_ok('/login')
    ->status_is(200)
    ->content_like(qr/Sign in to start your session/)
    ->content_unlike(qr/Invalid credentials/)
    ->element_exists('form input[name="username"]')
    ->element_exists('form input[name="password"]')
    ->element_exists('form button[type="submit"]');

  # Check invalid credentials message
  $t->post_ok(
    '/auth' => form => {
      username => 'invalid username',
      password => 'invalid password'
    }
  )->status_is(401)->content_like(qr/Invalid credentials/);
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

subtest 'Validate - GET register() controller method' => sub {

  # The id must exist for the controller to activate
  $t->get_ok('/public/register/')->status_is(404);

  # Must contain characters
  $t->get_ok('/public/register/  ')
    ->status_is(403)
    ->content_like(qr/Oops! Access denied./);

  # Must be exactly 8 characters
  $t->get_ok('/public/register/ABC')
    ->status_is(403)
    ->content_like(qr/Oops! Access denied./);
  $t->get_ok('/public/register/ABCDEFGHJ')
    ->status_is(403)
    ->content_like(qr/Oops! Access denied./);

  # Must contains only these characters [ ABCDEFGHJKLMNPQRTUVWXYZ2346789 ]
  $t->get_ok('/public/register/O0I1S5')
    ->status_is(403)
    ->content_like(qr/Oops! Access denied./);
  $t->get_ok('/public/register/!@#$%^&*')
    ->status_is(403)
    ->content_like(qr/Oops! Access denied./);

  my $valid_access_code = 'ABCD2346';

  # Contains only valid characters,
  # but the access code does not exist
  $t->get_ok("/public/register/$valid_access_code")
    ->status_is(403)
    ->content_like(qr/Oops! Access denied./);

  # Define the access code
  my $access_code = create_access_code($db, $valid_access_code);
  ok(defined $access_code);

  # Contains only valid characters,
  # but the access code does not exist
  $t->get_ok("/public/register/$valid_access_code")
    ->status_is(200)
    ->content_like(qr/Register a new membership/)
    ->element_exists('form input[name="first-name"]')
    ->element_exists('form input[name="last-name"]')
    ->element_exists('form input[name="middle-name"]')
    ->element_exists('form input[name="email"]')
    ->element_exists('form input[name="username"]')
    ->element_exists('form input[name="password"]')
    ->element_exists('form input[name="confirm-password"]')
    ->element_exists('form input[name="terms"]');
};

################################################################################

done_testing();
