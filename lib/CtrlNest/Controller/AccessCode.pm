package CtrlNest::Controller::AccessCode;
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
#        type        - The access code type provided by the client.
#        expires_in  - The expiration duration provided by the client.
#        is_reusable - Whether the access code is reusable, as provided by the
#                      client.
#
# @return
#   - HTTP 302 (Found) redirect to /settings/access_codes on success.
#   - HTTP 400 (Bad Request) on failure.
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

  my $error_found = 0;

  # If undefined, the insertion faild
  unless (defined $access_code) {

    # Flash the error message
    $self->flash(error_toast => 'Internal Server Error!');

    # 500 Internal Server Error
    $error_found = 1;
  }

  # Return error if the parameters are invalid
  if ($access_code == INVALID_PARAMS) {

    # Flash the error message
    $self->flash(error_toast => 'Invalid Parameters!');

    # 400 Bad Request
    $error_found = 1;
  }

  # Check for errors
  if ($error_found) {

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
