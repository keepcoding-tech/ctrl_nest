package CtrlNest::Controller::User;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use Mojo::Util 'md5_sum';
use File::Path 'make_path';

use CtrlNest::Helper::Constants;

################################################################################

# @brief Renders the user profile page. If a username parameter is provided, it
#        shows the profile of that user. Otherwise, it shows the profile of the
#        currently logged-in user.
#
# @method GET
#
# @param username - (Optional) The username of the profile to view. If not
#                   provided, defaults to the currently logged-in user's username.
#
# @return
#   - HTTP 200 (OK) Returns the rendered /user/profile page (HTML).
#
sub profile {
  my $self = shift;

  my $username = $self->param('username') // $self->session('username');

  # Get the current user
  my $user = $self->db->resultset('User')->get_by_username($username);

  return $self->render(
    layout => 'default',
    title  => 'Profile',
    u      => $user
  );
}

################################################################################

sub upload_avatar {
  my $self = shift;

  # Delegate to the helper function
  return upload_avatar($self);
}

################################################################################

1;
