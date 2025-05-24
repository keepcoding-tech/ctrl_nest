package CtrlNest::Controller::Dashboard;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use Time::Piece;

# This action will render a template
sub home ($self) {

  # Capture the application start time
  my $last_restart = localtime->strftime('%d %h, %Y');

  # Render template "dashboard/home.html.ep"
  $self->render(
    layout       => 'default',
    title        => 'Home',
    cpu_traffic  => '12',
    ram_memory   => '64',
    disk_space   => '164',
    last_restart => $last_restart
  );
}

1;
