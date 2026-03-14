use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Crypt::Bcrypt qw(bcrypt_check);

use CtrlNest::Helper::Auth;
use CtrlNest::Helper::Constants;

use lib 't';
use util::common;
use util::init;

# Init Mojo & Schema
my ($t, $db) = init_tests();

################################################################################

subtest 'Test authenticate_user_credentials() with random data' => sub {
  for (1 .. 4) {

    # Create a random valid username
    my $username = generate_random_username();

    # Create a random valid password
    my $password = generate_random_password();

    # Create a random user
    my $user = create_user($db, undef, undef, $username, undef, $password);
    ok(defined $user);

    # The password must mach
    my $result = authenticate_user_credentials($t->app, $username, $password);

    # The user must be returned
    is($result->{status},                                    SUCCESS);
    is($result->{data}->{username},                          $username);
    is(bcrypt_check($password, $result->{data}->{password}), SUCCESS);

    # The user must exist
    $result
      = authenticate_user_credentials($t->app, $username . 'x', $password);
    is($result->{status}, INVALID);
    is($result->{error},  'User not found');

    # The password most not mach if at least one char si different
    $result
      = authenticate_user_credentials($t->app, $username, $password . 'x');
    is($result->{status}, INVALID);
    is($result->{error},  'Password mismatch');
  }
};

################################################################################

subtest 'Test process_user_db_creation() with random data' => sub {
  for (1 .. 4) {

    # Create random valid user data
    my $first_name = generate_random_name();
    my $last_name  = generate_random_name();
    my $username   = generate_random_username();
    my $email      = generate_random_email();
    my $password   = generate_random_password();

    my $result = process_user_db_creation(
      $t->app, $first_name, $last_name, $username,
      $email,  $password,   $password
    );

    # Should pass for every test
    is($result->{status},                                    SUCCESS);
    is($result->{data}->{first_name},                        $first_name);
    is($result->{data}->{last_name},                         $last_name);
    is($result->{data}->{username},                          $username);
    is($result->{data}->{email},                             $email);
    is(bcrypt_check($password, $result->{data}->{password}), SUCCESS);

    # Confirmation password must be identical
    $result
      = process_user_db_creation($t->app, $first_name, $last_name, $username,
      $email, $password, 'NoN1dentic@lPassword');
    is($result->{status}, INVALID);
    is($result->{error},  'Confirmation password does not match');

    # Username must be unique
    $result = process_user_db_creation(
      $t->app, $first_name, $last_name, $username,
      $email,  $password,   $password
    );
    is($result->{status}, INVALID);
    is($result->{error},  'Username already in use');

    # Email must be unique
    $result
      = process_user_db_creation($t->app, $first_name, $last_name,
      generate_random_username(),
      $email, $password, $password);
    is($result->{status}, INVALID);
    is($result->{error},  'Email already in use');
  }
};

################################################################################

done_testing();
