package CtrlNest::Validator::User;
use Mojo::Base -base;

use CtrlNest::Helper::Constants;

use Exporter 'import';
our @EXPORT = qw(
  validate_email
  validate_first_name
  validate_last_name
  validate_password
  validate_username
);

################################################################################

# @brief Validates the email format and checks it against defined constraints.
#
# @param $email - The plain-text email provided by the user.
#
sub validate_email {
  my ($email) = @_;

  # Must exists
  unless (defined $email) {
    return {
      status => INVALID,
      error  => 'Email is required'
    };
  }

  # Trim whitespace
  $email =~ s/^\s+|\s+$//g;

  # Minimum and maximum length
  if (length($email) < USER_EMAIL_MIN_LEN) {
    return {
      status => INVALID,
      error  => 'Email must be at least '
        . USER_EMAIL_MIN_LEN
        . ' characters long'
    };
  }
  if (length($email) > USER_EMAIL_MAX_LEN) {
    return {
      status => INVALID,
      error  => 'Email must be at most '
        . USER_EMAIL_MAX_LEN
        . ' characters long'
    };
  }

  # Use a simple regex to filter obvious invalid emails
  unless ($email =~ USER_EMAIL_ALLOWED_FORMAT) {
    return {
      status => INVALID,
      error  => 'Email format is invalid'
    };
  }

  return {
    status => SUCCESS,
    data   => $email
  };
}

################################################################################

# @brief Validates a first name by checking it against defined constraints.
#
# @param $first_name - The plain-text provided by the user.
#
sub validate_first_name {
  my ($first_name) = @_;

  # Must exists
  unless (defined $first_name) {
    return {
      status => INVALID,
      error  => 'First name is required'
    };
  }

  # Trim whitespace
  $first_name =~ s/^\s+|\s+$//g;

  # Minimum and maximum length
  if (length($first_name) < USER_FIRST_NAME_MIN_LEN) {
    return {
      status => INVALID,
      error  => 'First name must be at least '
        . USER_FIRST_NAME_MIN_LEN
        . ' characters long'
    };
  }
  if (length($first_name) > USER_FIRST_NAME_MAX_LEN) {
    return {
      status => INVALID,
      error  => 'First name must be at most '
        . USER_FIRST_NAME_MAX_LEN
        . ' characters long'
    };
  }

  # Allowed characters: upper case and lower case letters only
  unless ($first_name =~ USER_FIRST_NAME_ALLOWED_CHARS) {
    return {
      status => INVALID,
      error  => 'First name can only contain letters'
    };
  }

  return {
    status => SUCCESS,
    data   => $first_name
  };
}

################################################################################

# @brief Validates a last name against defined constraints.
#
# @param $last_name - The plain-text provided by the user.
#
sub validate_last_name {
  my ($last_name) = @_;

  # Must exists
  unless (defined $last_name) {
    return {
      status => INVALID,
      error  => 'Last name is required'
    };
  }

  # Trim whitespace
  $last_name =~ s/^\s+|\s+$//g;

  # Minimum and maximum length
  if (length($last_name) < USER_LAST_NAME_MIN_LEN) {
    return {
      status => INVALID,
      error  => 'Last name must be at least '
        . USER_LAST_NAME_MIN_LEN
        . ' characters long'
    };
  }
  if (length($last_name) > USER_LAST_NAME_MAX_LEN) {
    return {
      status => INVALID,
      error  => 'Last name must be at most '
        . USER_LAST_NAME_MAX_LEN
        . ' characters long'
    };
  }

  # Allowed characters: upper/lower case letters, space and hyphen
  unless ($last_name =~ USER_LAST_NAME_ALLOWED_CHARS) {
    return {
      status => INVALID,
      error  => 'Last name can only contain letters, spaces and hyphens (-)'
    };
  }

  return {
    status => SUCCESS,
    data   => $last_name
  };
}

################################################################################

# @brief Validates a password by checking it against defined constraints.
#
# @param $password - The password string to validate.
#
sub validate_password {
  my ($password) = @_;

  # Must be defined
  unless (defined $password) {
    return {
      status => INVALID,
      error  => 'Password is required'
    };
  }

  # Must not contain null bytes
  if (index($password, "\0") != -1) {
    return {
      status => INVALID,
      error  => 'Password cannot contain null bytes'
    };
  }

  # Trim whitespace
  $password =~ s/^\s+|\s+$//g;

  # Minimum and maximum length
  if (length($password) < USER_PASSWORD_MIN_LEN) {
    return {
      status => INVALID,
      error  => 'Password must be at least '
        . USER_PASSWORD_MIN_LEN
        . ' characters long'
    };
  }
  if (length($password) > USER_PASSWORD_MAX_LEN) {
    return {
      status => INVALID,
      error  => 'Password must be at most '
        . USER_PASSWORD_MAX_LEN
        . ' characters long'
    };
  }

  # At least one lowercase letter
  unless ($password =~ /[a-z]/) {
    return {
      status => INVALID,
      error  => 'Password must contain at least one lowercase letter'
    };
  }

  # At least one uppercase letter
  unless ($password =~ /[A-Z]/) {
    return {
      status => INVALID,
      error  => 'Password must contain at least one uppercase letter'
    };
  }

  # At least one digit
  unless ($password =~ /\d/) {
    return {
      status => INVALID,
      error  => 'Password must contain at least one digit'
    };
  }

  # At least one special character [ ! @ # $ % ^ & * - ]
  unless ($password =~ /[!@#\$%\^&\*-]/) {
    return {
      status => INVALID,
      error  => 'Password must contain at least one special character '
        . '[ ! @ # $ % ^ & * - ]'
    };
  }

  # Allowed characters: letters, numbers and special characters
  unless ($password =~ USER_PASSWORD_ALLOWED_CHARS) {
    return {
      status => INVALID,
      error  => 'Password can only contain letters, numbers and these special '
        . 'characters: [ ! @ # $ % ^ & * - ]'
    };
  }

  return {
    status => SUCCESS,
    data   => $password
  };
}

################################################################################

# @brief Validates a username by checking it against defined constraints.
#
# @param $username - The username string to validate.
#
sub validate_username {
  my ($username) = @_;

  # Must be defined
  unless (defined $username) {
    return {
      status => INVALID,
      error  => 'Username is required'
    };
  }

  # Trim whitespace
  $username =~ s/^\s+|\s+$//g;

  # Length constraints
  if (length($username) < USER_USERNAME_MIN_LEN) {
    return {
      status => INVALID,
      error  => 'Username must be at least '
        . USER_USERNAME_MIN_LEN
        . ' characters long'
    };
  }
  if (length($username) > USER_USERNAME_MAX_LEN) {
    return {
      status => INVALID,
      error  => 'Username must be at most '
        . USER_USERNAME_MAX_LEN
        . ' characters long'
    };
  }

  # Allowed characters: letters, numbers, underscore and hyphen
  unless ($username =~ USER_USERNAME_ALLOWED_CHARS) {
    return {
      status => INVALID,
      error  => 'Username can only contain letters, numbers, '
        . 'underscores (_) and hyphens (-)'
    };
  }

  # Must start with a letter or number
  unless ($username =~ m{^[a-zA-Z0-9]}) {
    return {
      status => INVALID,
      error  => 'Username must start with a letter or number'
    };
  }

  return {
    status => SUCCESS,
    data   => $username
  };
}

################################################################################

1;
