package CtrlNest::Controller::AccessCode;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use CtrlNest::Helper::AccessCode;
use CtrlNest::Helper::Constants;

################################################################################

# @brief Handles access code creation by validating client-provided data. On
#        success, redirects the user to the access code view page. On failure,
#        redirects back to the creation page with an appropriate error message.
#
# @method POST
#
# @param title       - The access code title provided by the client.
#        type        - The access code type provided by the client.
#        expires_in  - The expiration duration provided by the client.
#        is_reusable - Whether the access code is reusable, as provided by the
#                      client.
#
# @return
#   - HTTP 302 (Found) redirect to /settings/access_codes on success.
#   - HTTP 302 (Found) redirect to /settings/access_codes with an error message.
#
sub create {
  my $self = shift;

  # Get all the parameters from the client
  my $ac_title       = $self->param('title');
  my $ac_type        = $self->param('type');
  my $ac_expires_in  = $self->param('expires_in');
  my $ac_is_reusable = $self->param('is_reusable') // CHECKBOX_UNCHECKED;

  # Get the current username
  my $ac_created_by = $self->session('user_uid');

  # Validate and create the access code in the database
  my $access_code = process_access_code_db_creation($self, $ac_title, $ac_type,
    $ac_expires_in, $ac_is_reusable, $ac_created_by);

  if ($access_code->{status} == INVALID) {
    $self->flash(error_toast => $access_code->{error});

    # Redirect user to the access codes view page with error message
    return $self->redirect_to('/settings/access_codes');
  }

  # Flash the success toast message
  $self->flash(success_toast => 1);

  # Redirect user to the access codes view page
  return $self->redirect_to('/settings/access_codes');
}

################################################################################

1;
