package CtrlNest::Validator::AccessCode;
use Mojo::Base -base;

use CtrlNest::Helper::Constants;

use Exporter 'import';
our @EXPORT = qw(
  validate_ac_code
  validate_ac_expires_in
  validate_ac_is_reusable
  validate_ac_title
  validate_ac_type
);

################################################################################

# @brief Validates the access code' unique code by checking it against
#        defined constraints.
#
# @param $code - The access code' unique code provided by the client.
#
sub validate_ac_code {
  my ($code) = @_;

  # The code must exist
  unless (defined $code) {
    return {
      status => INVALID,
      error  => 'Access code is required'
    };
  }

  # Trim whitespace
  $code =~ s/^\s+|\s+$//g;

  # Must be exactly 8 characters
  if (length($code) != ACCESS_CODE_LENGTH) {
    return {
      status => INVALID,
      error  => 'Access code must be exactly '
        . ACCESS_CODE_LENGTH
        . ' characters long'
    };
  }

  # The code must contain only allowd characters
  unless ($code =~ ACCESS_CODE_ALLOWED_CHARS) {
    return {
      status => INVALID,
      error  => 'Access code can only contain these characters: '
        . '[ ABCDEFGHJKLMNPQRTUVWXYZ2346789 ]'
    };
  }

  return {
    status => SUCCESS,
    data   => $code
  };
}

################################################################################

# @brief Validates an access code expiration duration by checking if the value
#        is one of the defined constant values.
#
# @param $access_code_expires_in - The expiration duration provided by the client.
#
sub validate_ac_expires_in {
  my ($access_code_expires_in) = @_;

  # Must be defined
  unless (defined $access_code_expires_in) {
    return {
      status => INVALID,
      error  => 'Access code expiration duration is required'
    };
  }

  # Must be a defined duration value
  if ( $access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_10_MIN
    || $access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_30_MIN
    || $access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_60_MIN
    || $access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_1_DAY
    || $access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_7_DAY
    || $access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_30_DAY
    || $access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_NEVER)
  {
    return {
      status => SUCCESS,
      data   => $access_code_expires_in
    };
  }

  return {
    status => INVALID,
    error  => 'Invalid access code expiration duration'
  };
}

################################################################################

# @brief Validates an access code reusability by checking it against
#        defined constraints. Also, if the parameter is valid, it will be
#        converted from a human-readable format to bit.
#
# @param $access_code_is_reusable - The human-readable reusability value.
#
sub validate_ac_is_reusable {
  my ($access_code_is_reusable) = @_;

  # Must be defined
  unless (defined $access_code_is_reusable) {
    return {
      status => INVALID,
      error  => 'Access code reusability is required'
    };
  }

  # Trim whitespace
  $access_code_is_reusable =~ s/^\s+|\s+$//g;

  # Must be one of the defined constant value
  if ( $access_code_is_reusable ne CHECKBOX_CHECKED
    && $access_code_is_reusable ne CHECKBOX_UNCHECKED)
  {
    return {
      status => INVALID,
      error  => 'Invalid access code reusability value'
    };
  }

  return {
    status => SUCCESS,
    data   => ($access_code_is_reusable eq CHECKBOX_CHECKED) ? 1 : 0
  };
}

################################################################################

# @brief Validates an access code title by checking it against defined
#        constraints.
#
# @param $title - The access code title to be validated.
#
sub validate_ac_title {
  my ($title) = @_;

  # Must be defined
  unless (defined $title) {
    return {
      status => INVALID,
      error  => 'Access code title is required'
    };
  }

  # Trim whitespace
  $title =~ s/^\s+|\s+$//g;

  # Minimum and maximum length
  if (length($title) < ACCESS_CODE_TITLE_MIN_LEN) {
    return {
      status => INVALID,
      error  => 'Access code title must be at least '
        . ACCESS_CODE_TITLE_MIN_LEN
        . ' characters long'
    };
  }
  if (length($title) > ACCESS_CODE_TITLE_MAX_LEN) {
    return {
      status => INVALID,
      error  => 'Access code title must be at most '
        . ACCESS_CODE_TITLE_MAX_LEN
        . ' characters long'
    };
  }

  # Allowed characters: letters, numbers and spaces
  unless ($title =~ ACCESS_CODE_TITLE_ALLOWED_CHARS) {
    return {
      status => INVALID,
      error  => 'Access code title can only contain'
        . ' letters, numbers and spaces'
    };
  }

  return {
    status => SUCCESS,
    data   => $title
  };
}

################################################################################

# @brief Validates an access code type by checking it against defined
#        constraints. Also, if the parameter is valid, it will be converted from
#        a human-readable format to bitmask.
#
# @param $access_code_type - The human-readable type value (e.g. '2fa').
#
sub validate_ac_type {
  my ($access_code_type) = @_;

  # Must be defined
  unless (defined $access_code_type) {
    return {
      status => INVALID,
      error  => 'Access code type is required'
    };
  }

  # Trim whitespace
  $access_code_type =~ s/^\s+|\s+$//g;

  # Must be one of the defined constant value
  if ( $access_code_type eq ACCESS_CODE_TYPE_ALL_RIGHTS
    || $access_code_type eq ACCESS_CODE_TYPE_REGISTER
    || $access_code_type eq ACCESS_CODE_TYPE_2FA)
  {
    return {
      status => SUCCESS,
      data   => $access_code_type
    };
  }

  return {
    status => INVALID,
    error  => 'Invalid access code type value'
  };
}

################################################################################

1;
