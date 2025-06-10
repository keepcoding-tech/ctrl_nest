package CtrlNest::Controller::Settings;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use Bytes::Random::Secure qw(random_string_from);

use CtrlNest::Helper::Constants;
use CtrlNest::Helper::AccessCode qw(normalize_access_codes);

################################################################################

sub access_codes {
  my $self = shift;

  # Get all access codes
  my @access_codes = $self->db->resultset('AccessCode')->get_all;

  # @access_codes = normalize_access_codes(@access_codes);

  return $self->render(
    layout       => 'default',
    title        => 'Access Codes',
    access_codes => \@access_codes
  );
}

################################################################################

sub create_access_code {
  my $self = shift;

  my $code_name = $self->param('code-name');

  my $access_code = $self->db->resultset('AccessCode')->create({
    code =>
      random_string_from('ABCDEFGHJKLMNPQRTUVWXYZ2346789', ACCESS_CODE_LEN),
    code_name  => $code_name,
    expires_at => DateTime->now->add(seconds => 3600)
  });

  return $self->redirect_to('/settings/access-codes');
}

################################################################################

sub home {
  my $self = shift;

  return $self->render(
    layout => 'default',
    title  => 'Settings'
  );
}

################################################################################

1;
