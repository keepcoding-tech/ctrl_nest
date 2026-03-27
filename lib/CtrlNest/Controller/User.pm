package CtrlNest::Controller::User;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use Mojo::Util 'md5_sum';
use File::Path 'make_path';

use CtrlNest::Helper::Constants;
use CtrlNest::Helper::Pagination;
use CtrlNest::Validator::Pagination;

################################################################################

# @brief
#
# @method POST
#
# @param username  - The username of the user to be modified.
#        new_email - The new primary email for the user.
#
# @return
#   - HTTP 302 (Found) On success, redirects to the user profile page.
#   - HTTP 302 (Found) On fail, redirects to the account settings with error.
#
sub change_email {
  my $self = shift;

  # Get all the parameters
  my $username  = $self->param('username');
  my $new_email = $self->param('new_email');

  use Data::Dumper;
  warn "\n\n";
  warn Dumper($username, $new_email);
  warn "\n\n";

  # TODO:
  # - validate parameters
  #   - redirect to account settings with error
  # - check for the availability of the new email
  #   - redirect to account settings with error
  # - send verification code
  #   - redirect to account settings with error
  # - redirect to the user profile with message about the verification code


  return $self->redirect_to('/user/profile/');
}

################################################################################

# @brief
#
# @method POST
#
# @param username             - The username of the user to be modified.
#        old_password         - The current password of the user.
#        new_password         - The new password of the user.
#        confirm_new_password - The confirmed new password of the user.
#
# @return
#   - HTTP 302 (Found) On success, redirects to the login page.
#   - HTTP 302 (Found) On fail, redirects to the account settings with error.
#
sub change_password {
  my $self = shift;

  # Get all the parameters
  my $username      = $self->param('username');
  my $old_password  = $self->param('old_password');
  my $new_password  = $self->param('new_password');
  my $conf_new_pass = $self->param('confirm_new_password');

  use Data::Dumper;
  warn "\n\n";
  warn Dumper($username, $old_password, $new_password, $conf_new_pass);
  warn "\n\n";

  # TODO:
  # - validate parameters
  #   - redirect to account settings with error
  # - update new password in the DB
  # - end session and redirect to login page

  return $self->redirect_to('/user/profile/');
}

################################################################################

# @brief
#
# @method POST
#
# @param old_username - The username to be changed.
#        new_username - The new username for the user.
#
# @return
#   - HTTP 302 (Found) On success, redirects to the user profile page.
#   - HTTP 302 (Found) On fail, redirects to the modal with error.
#
sub change_username {
  my $self = shift;

  # Get all the parameters
  my $old_username = $self->param('old_username');
  my $new_username = $self->param('new_username');

  use Data::Dumper;
  warn "\n\n";
  warn Dumper($old_username, $new_username);
  warn "\n\n";

  # TODO:
  # - validate parameters
  #   - redirect to the modal with error
  # - check for the availability of the new username
  #   - redirect to the modal with error
  # - update username
  #   - redirect to the modal with error
  # - reload session
  # - redirect to the user profile with success toast


  return $self->redirect_to('/user/profile/');
}

################################################################################

# @brief
#
# @method POST
#
# @param username         - The username of the user to be deleted.
#        confirm_username - The confirmation username of the user to be deleted.
#        undersigned      - A predefined text to make sure is not a mistake.
#
# @return
#   - HTTP 302 (Found) On success, redirects to the login page.
#   - HTTP 302 (Found) On fail, redirects to the modal with error.
#
sub delete_user {
  my $self = shift;

  # Get all the parameters
  my $username      = $self->param('username');
  my $conf_username = $self->param('confirm_username');
  my $undersigned   = $self->param('undersigned');

  use Data::Dumper;
  warn "\n\n";
  warn Dumper($username, $conf_username, $undersigned);
  warn "\n\n";

  # TODO:
  # - validate parameters
  #   - redirect to the modal with error
  # - delete user from DB
  # - end session
  # - redirect to login page


  return $self->redirect_to('/login');
}

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

# @brief Renders the user profile page for the Account settings.
#
# @method GET
#
# @param username - The username of the profile to view or modify.
#
# @return
#   - HTTP 200 (OK) Returns the rendered /user/profile_settings_account
#     page (HTML).
#   - HTTP 404 (Not Found) If the username cannot be found, returns a
#     not found page.
#
sub profile_settings_account {
  my $self = shift;

  # Get the parameter
  my $username = $self->param('username');

  # Get the requested user data
  my $user = $self->db->resultset('User')->get_by_username($username);

  # If not found, return 404
  unless (defined $user) {
    return $self->reply->html_not_found;
  }

  return $self->render(
    layout => 'default',
    title  => 'Profile settings | Account',
    u      => $user
  );
}

################################################################################

# @brief Renders the user profile page for the Contact settings.
#
# @method GET
#
# @param username - The username of the profile to view or modify.
#
# @return
#   - HTTP 200 (OK) Returns the rendered /user/profile_settings_contact
#     page (HTML).
#   - HTTP 404 (Not Found) If the username cannot be found, returns a
#     not found page.
#
sub profile_settings_contact {
  my $self = shift;

  # Get the parameter
  my $username = $self->param('username');

  # Get the requested user data
  my $user = $self->db->resultset('User')->get_by_username($username);

  # If not found, return 404
  unless (defined $user) {
    return $self->reply->html_not_found;
  }

  return $self->render(
    layout => 'default',
    title  => 'Profile settings | Contact',
    u      => $user
  );
}

################################################################################

# @brief Renders the user profile page for the Location settings.
#
# @method GET
#
# @param username - The username of the profile to view or modify.
#
# @return
#   - HTTP 200 (OK) Returns the rendered /user/profile_settings_location
#     page (HTML).
#   - HTTP 404 (Not Found) If the username cannot be found, returns a
#     not found page.
#
sub profile_settings_location {
  my $self = shift;

  # Get the parameter
  my $username = $self->param('username');

  # Get the requested user data
  my $user = $self->db->resultset('User')->get_by_username($username);

  # If not found, return 404
  unless (defined $user) {
    return $self->reply->html_not_found;
  }

  return $self->render(
    layout => 'default',
    title  => 'Profile settings | Location',
    u      => $user
  );
}

################################################################################

# @brief Renders the user profile page for the Public settings.
#
# @method GET
#
# @param username - The username of the profile to view or modify.
#
# @return
#   - HTTP 200 (OK) Returns the rendered /user/profile_settings_public
#     page (HTML).
#   - HTTP 404 (Not Found) If the username cannot be found, returns a
#     not found page.
#
sub profile_settings_public {
  my $self = shift;

  # Get the parameter
  my $username = $self->param('username');

  # Get the requested user data
  my $user = $self->db->resultset('User')->get_by_username($username);

  # If not found, return 404
  unless (defined $user) {
    return $self->reply->html_not_found;
  }

  return $self->render(
    layout   => 'default',
    title    => 'Profile settings | Public',
    username => $username,
    u        => $user
  );
}

################################################################################

# @brief
#
# @method POST
#
# @param username      - The username of the user to be modified.
#        mobile_phone  - The mobile phone number of the user.
#        fix_phone     - The fix phone number of the user.
#        contact_email - The preferred contact email address of the user.
#
# @return
#   - HTTP 302 (Found) On success, redirects to the user' profile settings.
#
sub update_public_contact {
  my $self = shift;

  # Get all the parameter
  my $username      = $self->param('username');
  my $mobile_phone  = $self->param('mobile_phone');
  my $fix_phone     = $self->param('fix_phone');
  my $contact_email = $self->param('contact_email');

  use Data::Dumper;
  warn "\n\n";
  warn Dumper($username, $mobile_phone, $fix_phone, $contact_email);
  warn "\n\n";

  # TODO:
  # - validate public info
  #   - return error toast
  # - update data in DB
  #   - return error toast if 500
  #   - return success toast

  return $self->redirect_to("/user/profile/settings/$username/contact");
}

################################################################################

# @brief
#
# @method POST
#
# @param username - The username of the user to be modified.
#        contry   - The country where the user is located.
#        region   - The region (within the country) where the user is located.
#        city     - The city (within the region) where the user is located.
#        address  - The address (str, nr, bl. etc) where the user is located.
#        zip_code - The zip code of the user' location.
#
# @return
#   - HTTP 302 (Found) On success, redirects to the user' profile settings.
#
sub update_public_location {
  my $self = shift;

  # Get all the parameter
  my $username = $self->param('username');
  my $country  = $self->param('country');
  my $region   = $self->param('region');
  my $city     = $self->param('city');
  my $address  = $self->param('address');
  my $zip_code = $self->param('zip_code');

  use Data::Dumper;
  warn "\n\n";
  warn Dumper($username, $country, $region, $city, $address, $zip_code);
  warn "\n\n";

  # TODO:
  # - validate public info
  #   - return error toast
  # - update data in DB
  #   - return error toast if 500
  #   - return success toast

  return $self->redirect_to("/user/profile/settings/$username/location");
}

################################################################################

# @brief
#
# @method POST
#
# @param username   - The username of the user to be modified.
#        avatar     - The file of the avatar image.
#        first_name - The first name of the user.
#        last_name  - The last name of the user.
#        bio        - The bio of the user.
#
# @return
#   - HTTP 302 (Found) On success, redirects to the user' profile settings.
#
sub update_public_profile {
  my $self = shift;

  # Get all the parameter
  my $username   = $self->param('username');
  my $avatar     = $self->req->upload('avatar');
  my $first_name = $self->param('first_name');
  my $last_name  = $self->param('last_name');
  my $bio        = $self->param('bio');

  use Data::Dumper;
  warn "\n\n";
  warn Dumper($username, $avatar, $first_name, $last_name, $bio);
  warn "\n\n";

  # TODO:
  # - validate public info
  #   - return error toast
  # - update data in DB
  #   - return error toast if 500
  #   - return success toast

  return $self->redirect_to("/user/profile/settings/$username/public");
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
