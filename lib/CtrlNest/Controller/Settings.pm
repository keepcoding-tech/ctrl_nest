package CtrlNest::Controller::Settings;
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
#   - HTTP 200 (OK) Returns the rendered /settings/access_codes page (HTML).
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

  # Render template "settings/users.html.ep"
  return $self->render(
    layout         => 'default',
    title          => 'Access Codes',
    access_codes   => \@access_codes,
    search_keyword => $search,
    pagination     => $pagination
  );
}

################################################################################

# @brief Renders the settings home page.
#
# @method GET
#
# @param
#
# @return
#   - HTTP 200 (OK) Returns the rendered /settings page (HTML).
#
sub settings {
  my $self = shift;

  # Get the number of all the rows in the access_codes table
  my $access_codes_count = $self->db->resultset('AccessCode')->get_count();

  # Get the number of all the rows in the users table
  my $users_count = $self->db->resultset('User')->get_count();

  # Render template "settings/settings.html.ep"
  return $self->render(
    layout             => 'default',
    title              => 'Settings',
    access_codes_count => $access_codes_count,
    users_count        => $users_count
  );
}

################################################################################

# @brief Renders the settings users list page.
#
# @method GET
#
# @param page   - The page number of the table (for pagination).
#        search - The keyword to be searched.
#
# @return
#   - HTTP 200 (OK) Returns the rendered /settings/users page (HTML).
#
sub users {
  my $self = shift;

  # Get all the parameters or default them if not existing
  my $page   = $self->param('page');
  my $search = $self->param('search');

  # Replace with default values if invalid
  $page   = 1  unless validate_page_number($page)->{status} == SUCCESS;
  $search = '' unless validate_search_keyword($search)->{status} == SUCCESS;

  # Get the paginated users list
  my $users_rs = $self->db->resultset('User')->get_paginated($search, $page);

  # Get pagination object
  my $pagination = get_pagination($users_rs->pager, $page);

  # Map the result set to hashref
  my @users = map { {
    full_name  => $_->first_name . ' ' . $_->last_name,
    username   => $_->username,
    email      => $_->email,
    role       => $_->role,
    created_at => $_->created_at->strftime('%d %h, %Y')
  } } $users_rs->all;

  # Render template "settings/users.html.ep"
  return $self->render(
    layout         => 'default',
    title          => 'Users',
    users          => \@users,
    search_keyword => $search,
    pagination     => $pagination
  );
}

################################################################################

1;
