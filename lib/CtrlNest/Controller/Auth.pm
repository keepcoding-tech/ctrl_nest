package CtrlNest::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use CtrlNest::Helper::AccessCode qw(validate_access_code);
use CtrlNest::Helper::Auth       qw(validate_auth);
use CtrlNest::Helper::Constants;

################################################################################

# @brief Handles user authentication on sign-in attempt.
#   Verifies provided username and password against stored credentials.
#   On success, redirects the user to the home page.
#   On failure, re-renders the login page with an "Invalid credentials" message.
#
# @method POST
#
# @param username - Username received from the client.
#        password - Password received from the client.
#
# @return
#   - HTTP 302 (Found) if succesfull.
#   - HTTP 401 (Unauthorized) if unauthorized.
#
sub auth {
  my $self = shift;

  # Get username and password parameters
  my $username = $self->param('username');
  my $password = $self->param('password');

  # Search for the user and validate the authentication
  my $user = validate_auth($self, $username, $password);

  # if undefined, the authenitcation failed
  unless (defined $user) {

    # Re-render the /login page with error message
    return $self->render(
      layout           => 'auth',
      template         => 'auth/login',
      title            => 'Login',
      validation_error => 'Invalid credentials',

      # Specific HTTP status
      status => 401
    );
  }

  # Create user session
  $self->session(
    user_id => $user->{id},

    # first_name => $user->{first_name},
    # last_name  => $user->{last_name},
    username => $user->{username},
    role     => $user->{role}
  );

  # Redirect to /home page
  return $self->redirect_to('/home');
}

################################################################################

# @brief Renders the lock screen page.
#
# @method GET
#
# @param
#
# @return HTTP 200 (OK)
#   - Returns the rendered /lockscreen page (HTML).
#
sub lockscreen {
  my $self = shift;

  # Get the username before ending the session
  my $username = $self->session('username') // SESSION_NOT_FOUND;

  # End session
  $self->session(expires => 1);

  # Render template "auth/lockscreen.html.ep"
  return $self->render(
    layout   => 'auth',
    title    => 'Lockscreen',
    username => $username,
  );
}

################################################################################

# @brief Renders the login page.
#
# @method GET
#
# @param
#
# @return HTTP 200 (OK)
#   - Returns the rendered /login page (HTML).
#
sub login {
  my $self = shift;

  # Render template "auth/login.html.ep"
  return $self->render(
    layout => 'auth',
    title  => 'Login',
  );
}

################################################################################

# @brief Handles user sign-out.
#   Expires the current session and redirects the user to the login page.
#
# @method POST
#
# @param
#
# @return HTTP 302 (Found)
#
sub logout {
  my $self = shift;

  # End session
  $self->session(expires => 1);

  # Redirect user to the login page
  return $self->redirect_to('/login');
}

################################################################################

# @brief Renders the registration page.
#
# @method GET
#
# @param access-code - The access code required to create a new user.
#
# @return
#   - The rendered /register page (HTML) if the access code is valid.
#   - A 403 Forbidden page if the access code is invalid or missing.
#
sub register {
  my $self = shift;

  # Get the access code
  my $access_code = $self->param('access-code');

  # Validate the access code
  return $self->render(template => 'error/403', status => 403)
    unless validate_access_code($self, $access_code) == SUCCESS;

  # Render template "auth/register.html.ep"
  return $self->render(
    layout      => 'auth',
    title       => 'Register',
    access_code => $access_code
  );
}

################################################################################

# @brief
#
# @method POST
#
# @param access_code      - The access code needed to create a new user.
#        first-name       - First name received from the client.
#        last-name        - Last name received from the client.
#        middle-name      - Middle name (optional) received from the client.
#        email            - Email received from the client.
#        username         - Username received from the client.
#        password         - Password received from the client.
#        confirm-password - Retyped password received from the client.
#        terms            - Agrees with the terms and conditions.
#
# @return
#
sub register_new_user {
  my $self = shift;

  # TODO:
  #   - Create AccessCode system

  # Get all the parameters
  my $access_code      = $self->param('access-code');
  my $first_name       = $self->param('first-name');
  my $last_name        = $self->param('last-name');
  my $middle_name      = $self->param('middle-name');
  my $email            = $self->param('email');
  my $username         = $self->param('username');
  my $password         = $self->param('password');
  my $confirm_password = $self->param('confirm-password');
  my $terms            = $self->param('terms');

  warn "\n\n";
  warn $access_code;
  warn $first_name;
  warn $last_name;
  warn $middle_name;
  warn $email;
  warn $username;
  warn $password;
  warn $confirm_password;
  warn $terms;
  warn "\n\n";

  # Render the /register template.
  return $self->redirect_to('/login');
}

################################################################################

# @brief Handles the `before_dispatch` hook.
#   Checks whether the requested URL requires authentication.
#   If the route is not publicly accessible and the user is not authenticated,
#   redirects to the /login page.
#
# @method HOOK (before_dispatch)
#
# @param
#
# @return
#   - HTTP 302 (Found) redirect to /login if access is unauthorized.
#   - Otherwise, continues request processing.
#
sub require_auth {
  my $self = shift;

  # Get the URL path
  my $url_path = $self->req->url->path->to_string;

  # Skip for public pages
  return if $url_path =~ m{^/public};

  # Skip for dedicated pages
  return
       if ($url_path eq '/login')
    or ($url_path eq '/register')
    or ($url_path eq '/lockscreen')
    or ($url_path eq '/auth');

  # Skip auth for static assets (like CSS, JS, images, fonts)
  return if $url_path =~ /\.(css|js|png|jpg|jpeg|gif|svg|woff2?|ttf|eot|ico)$/i;

  # Redirect to login if NOT authenticated
  unless ($self->session('user_id')) {
    return $self->redirect_to('/login');
  }
}

################################################################################

1;
