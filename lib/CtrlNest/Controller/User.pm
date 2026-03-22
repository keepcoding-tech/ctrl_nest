package CtrlNest::Controller::User;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use Mojo::Util 'md5_sum';
use File::Path 'make_path';

use CtrlNest::Helper::Constants;
use CtrlNest::Helper::Pagination;
use CtrlNest::Validator::Pagination;

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

# @brief Renders the settings users list page.
#
# @method GET
#
# @param page   - The page number of the table (for pagination).
#        search - The keyword to be searched.
#
# @return
#   - HTTP 200 (OK) Returns the rendered /user/users page (HTML).
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

  # Render template "user/users.html.ep"
  return $self->render(
    layout         => 'default',
    title          => 'Users',
    users          => \@users,
    search_keyword => $search,
    pagination     => $pagination
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
