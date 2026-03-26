package CtrlNest;
use Mojo::Base 'Mojolicious', -signatures;

use CtrlNest::Helper::Constants;
use CtrlNest::Schema;

# This method will run once at server start
sub startup ($self) {

  # Configure the application
  $self->secrets([ $ENV{MOJO_SECRETS} ]);
  $self->sessions->default_expiration(SESSION_TIMEOUT);

  # DB (create connection string)
  my $pg_dsn  = $ENV{DBI_DSN};
  my $pg_user = $ENV{DBI_USER};
  my $pg_pass = $ENV{DBI_PASS};

  # Connect DB
  my $schema = CtrlNest::Schema->connect($pg_dsn, $pg_user, $pg_pass);

  $self->helper(db => sub {$schema});

  # Router
  my $r = $self->routes;

  # -------------------------------------------------------------------------- #

  # Auth GET
  $r->get('/lockscreen')->to(
    controller => 'Auth',
    action     => 'lockscreen'
  );
  $r->get('/login')->to(
    controller => 'Auth',
    action     => 'login',
  );
  $r->get('/signup/:code')->to(
    controller => 'Auth',
    action     => 'signup'
  );

  # Auth POST
  $r->post('/auth')->to(
    controller => 'Auth',
    action     => 'auth'
  );
  $r->post('/logout')->to(
    controller => 'Auth',
    action     => 'logout'
  );
  $r->post('/register')->to(
    controller => 'Auth',
    action     => 'register'
  );

  # All routes under this path will require authentication
  my $auth = $r->under('/')->to(
    controller => 'Auth',
    action     => 'require_auth'
  );

  # -------------------------------------------------------------------------- #

  # Access Code GET
  $auth->get('/access_codes')->to(
    controller => 'AccessCode',
    action     => 'access_codes'
  );

  # Access Code POST
  $auth->post('/access_code/create')->to(
    controller => 'AccessCode',
    action     => 'create'
  );

  # -------------------------------------------------------------------------- #

  # Dashboard GET
  $auth->get('/')->to(
    controller => 'Dashboard',
    action     => 'home'
  );
  $auth->get('/home')->to(
    controller => 'Dashboard',
    action     => 'home'
  );

  # -------------------------------------------------------------------------- #

  # User GET
  $auth->get('/users')->to(
    controller => 'User',
    action     => 'users'
  );
  $auth->get('/user/profile')->to(
    controller => 'User',
    action     => 'profile'
  );
  $auth->get('/user/profile/:username')->to(
    controller => 'User',
    action     => 'profile'
  );

  # User POST
  $auth->post('/user/profile/upload_avatar')->to(
    controller => 'User',
    action     => 'upload_avatar'
  );

  # -------------------------------------------------------------------------- #

  return;
}

1;
