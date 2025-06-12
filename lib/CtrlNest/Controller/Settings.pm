package CtrlNest::Controller::Settings;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use CtrlNest::Helper::AccessCode;
use CtrlNest::Helper::Constants;

################################################################################

# @brief Handles access code creation by validating client-provided data.
#   On success, redirects the user to the access code view page.
#   On failure, redirects back to the creation page with an "Invalid Parameters"
#   message.
#
# @method POST
#
# @param title       - The access code title provided by the client.
#        expires-in  - The expiration duration provided by the client.
#        type        - The access code type provided by the client.
#        is-reusable - Whether the access code is reusable, as provided by the
#                      client.
#
# @return
#   - HTTP 200 (OK) on success.
#   - HTTP 400 (Bad Request) on failure.
#
sub access_code_create {
  my $self = shift;

  # Get all the parameters from the client
  my $ac_title       = $self->param('title');
  my $ac_expires_in  = $self->param('expires-in');
  my $ac_type        = $self->param('type');
  my $ac_is_reusable = $self->param('is-reusable') // CHECKBOX_UNCHECKED;

  # Get the current username
  my $ac_created_by = $self->session('username');

  # Validate and create the access code in the database
  my $access_code = process_access_code_db_creation($self, $ac_title,
    $ac_expires_in, $ac_type, $ac_is_reusable, $ac_created_by);

  # Return error if the parameters are invalid
  if ($access_code == INVALID_PARAMS) {

    # Flash the error message
    $self->flash(ac_error => 'Invalid Parameters');

    # Redirects to the /settings page with error message
    return $self->redirect_to('/settings');
  }

  # If undefined, the insertion faild
  unless (defined $access_code) {

    # Flash the error message
    $self->flash(ac_error => 'Internal Server Error');

    # Redirects to the /settings page with error message
    return $self->redirect_to('/settings');
  }

  # TODO:
  # - redirect user to the access code view page.
  return $self->render(
    layout      => 'default',
    template    => 'settings/home',
    title       => 'Settings',
    access_code => $access_code->code
  );
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
