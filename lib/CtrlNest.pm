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

  $self->helper(
    db    => sub {$schema},
    const => sub {CtrlNest::Helper::Constants::}
  );

  # Router
  my $r = $self->routes;

  # ========================================================================== #

  # Auth GET
  $r->get('/lockscreen')->to('Auth#lockscreen');
  $r->get('/login')->to('Auth#login');
  $r->get('/public/register/:access-code')->to('Auth#register');

  # Auth POST
  $r->post('/auth')->to('Auth#auth');
  $r->post('/logout')->to('Auth#logout');
  $r->post('/register')->to('Auth#register_new_user');

  # Redirect to /login if not authenticated
  $self->hook(
    before_dispatch => sub {
      my $c = shift;
      CtrlNest::Controller::Auth::require_auth($c);
    }
  );

  # ========================================================================== #

  # Dashboard GET
  $r->get('/')->to('Dashboard#home');
  $r->get('/home')->to('Dashboard#home');

  # ========================================================================== #

  # Settings GET
  $r->get('/settings')->to('Settings#home');
  $r->get('/settings/access-codes')->to('Settings#access_codes');

  # Settings POST
  $r->post('/settings/access-code/create')->to('Settings#create_access_code');

  # ========================================================================== #

  return;
}

1;
