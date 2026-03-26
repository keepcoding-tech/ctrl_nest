package CtrlNest::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use CtrlNest::Helper::AccessCode;
use CtrlNest::Helper::Auth;
use CtrlNest::Helper::Constants;
use CtrlNest::Validator::AccessCode;

################################################################################

# @brief Handles user authentication on sign-in attempt. Verifies provided
#        username and password against stored credentials. On success, redirects
#        the user to the home page. On failure, redirects to the login page with
#        an appropriate error message.
#
# @method POST
#
# @param username - Username received from the client.
#        password - Password received from the client.
#
# @return
#   - HTTP 302 (Found) Redirect to the home page if succesfull.
#   - HTTP 302 (Found) Redirect back to the login page if unauthorized.
#
sub auth {
  my $self = shift;

  # Get username and password parameters
  my $username = $self->param('username');
  my $password = $self->param('password');

  # Search for the user and validate the authentication
  my $authenticate = authenticate_user_credentials($self, $username, $password);

  if ($authenticate->{status} == INVALID) {

    # We don't want to show the "real" validation error. From a security
    # perspective, the only problem for the user is if the username or password
    # is wrong.
    $self->flash(auth_failed => 1);

    # Redirect to the login page with error message
    return $self->redirect_to('/login');
  }

  # Create user session
  $self->session(
    user_uid => $authenticate->{data}->{uid},
    username => $authenticate->{data}->{username},
    role     => $authenticate->{data}->{role}
  );

  # Redirect to /home page
  return $self->redirect_to('/home');
}

################################################################################

# @brief Renders the lockscreen page and ends session.
#
# @method GET
#
# @param
#
# @return
#   - HTTP 200 (OK) Returns the rendered /auth/lockscreen page (HTML).
#   - HTTP 302 (Found) Redirect back to the login page if cannot find session.
#
sub lockscreen {
  my $self = shift;

  # Get the username before ending the session
  my $username = $self->session('username');

  # Redirect back to the login page if cannot find session
  unless (defined $username) {
    return $self->redirect_to('/login');
  }

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
# @return
#   - HTTP 200 (OK) Returns the rendered /auth/login page (HTML).
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

# @brief Handles user sign-out. Expires the current session and redirects the
#        user to the login page.
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

# @brief Handles user registration on sign-up attempt. Validates the provided
#        access code and user data. On success, creates a new user, initiates a
#        session, and redirects to the home page. On failure, redirects back to
#        the signup page with an appropriate error message.
#
# @method POST
#
# @param code             - The access code provided by the client for registration.
#        first_name       - The first name provided by the client.
#        last_name        - The last name provided by the client.
#        username         - The desired username provided by the client.
#        email            - The email address provided by the client.
#        password         - The desired password provided by the client.
#        confirm_password - The password confirmation provided by the client.
#
# @return
#   - HTTP 302 (Found) On success, redirects to the user' profile.
#   - HTTP 404 (Not Found) On invalid access code, returns a not found page.
#   - HTTP 302 (Found) On failure, redirects back to the signup page with an
#                      error message.
#
sub register {
  my $self = shift;

  # Get all the parameters
  my $code       = $self->param('access_code');
  my $first_name = $self->param('first_name');
  my $last_name  = $self->param('last_name');
  my $username   = $self->param('username');
  my $email      = $self->param('email');
  my $password   = $self->param('password');
  my $conf_pass  = $self->param('confirm_password');

  # Flash the parameters to maintain the
  # values for the inputs after redirect
  $self->flash(
    first_name       => $first_name,
    last_name        => $last_name,
    username         => $username,
    email            => $email,
    password         => $password,
    confirm_password => $conf_pass
  );

  # 404 if the access code is invalid
  return $self->reply->html_not_found
    unless verify_access_code_validity($self, $code, ACCESS_CODE_TYPE_REGISTER)
    ->{status} == SUCCESS;

  # Validate and create the user in the database
  my $new_user = process_user_db_creation($self, $first_name, $last_name,
    $username, $email, $password, $conf_pass);

  if ($new_user->{status} == INVALID) {
    $self->flash(error => $new_user->{error});

    # Redirect user to the signup page with error message
    return $self->redirect_to("/signup/$code");
  }

  # Mark the access code as used if it is non-reusable
  $self->db->resultset('AccessCode')->mark_expired($code);

  # Create user session
  $self->session(
    user_uid => $new_user->{data}->{uid},
    username => $new_user->{data}->{username},
    role     => $new_user->{data}->{role}
  );

  # Redirect to the user's profile page
  return $self->redirect_to("/user/profile/$username");
}

################################################################################

# @brief Hook method that enforces authentication before allowing access
#        to routes. If a user session exists, the request proceeds; otherwise,
#        the client is redirected to the login page.
#
# @method HOOK (before_dispatch)
#
# @param
#
# @return
#   - 1 (SUCCESS) if the user is authenticated and the request should continue.
#   - HTTP 302 (Found) redirect to '/login' if the user is not authenticated.
#
sub require_auth {
  my $self = shift;

  # Return true if the user is logged in
  return SUCCESS if $self->session('user_uid');

  # Redirect to login page if the user is not logged in
  return $self->redirect_to('/login');
}

################################################################################

# @brief Will render the signup page if the access code is valid.
#
# @method GET
#
# @param code - The access code to be used for signing up a new user.
#
# @return
#   HTTP 404 (Not Found) - The Access code is no longer valid.
#   HTTP 200 (OK) - Returns the rendered /auth/signup page (HTML).
#
sub signup {
  my $self = shift;

  # Get the access code and validate it
  my $code = $self->param('code');

  # Return 404 if the access code is invalid
  return $self->reply->html_not_found
    unless verify_access_code_validity($self, $code, ACCESS_CODE_TYPE_REGISTER)
    ->{status} == SUCCESS;

  # Render template "auth/signup.html.ep"
  return $self->render(
    layout => 'auth',
    title  => 'Register',
    code   => $code
  );
}

################################################################################

1;
