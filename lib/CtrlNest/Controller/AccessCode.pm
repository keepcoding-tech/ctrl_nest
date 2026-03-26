package CtrlNest::Controller::AccessCode;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use CtrlNest::Helper::AccessCode;
use CtrlNest::Helper::Constants;
use CtrlNest::Helper::Pagination;
use CtrlNest::Validator::Pagination;

################################################################################

# @brief Renders the settings access codes list page.
#
# @method GET
#
# @param page   - The page number of the table (for pagination).
#        search - The keyword to be searched.
#
# @return
#   - HTTP 200 (OK) Returns the rendered /access_code/access_codes page (HTML).
#
sub access_codes {
  my $self = shift;

  # Get all the parameters
  my $page   = $self->param('page');
  my $search = $self->param('search');

  # Replace with default values if invalid
  $page   = 1  unless validate_page_number($page)->{status} == SUCCESS;
  $search = '' unless validate_search_keyword($search)->{status} == SUCCESS;

  # Get the paginated access codes list
  my $ac_rs = $self->db->resultset('AccessCode')->get_paginated($search, $page);

  # Get pagination object
  my $pagination = get_pagination($ac_rs->pager, $page);

  # Map the result set to hashref
  my @access_codes = map { {
    code       => $_->code,
    status     => check_ac_availability($_) ? 0 : 1,
    title      => $_->title,
    type       => $_->type,
    created_by => $_->get_column('username'),
    created_at => $_->created_at->strftime('%d %h, %Y'),
  } } $ac_rs->all;

  # Render template "access_code/access_codes.html.ep"
  return $self->render(
    layout         => 'default',
    title          => 'Access Codes',
    access_codes   => \@access_codes,
    search_keyword => $search,
    pagination     => $pagination
  );
}

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
