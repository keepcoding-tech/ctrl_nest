package CtrlNest::Helper::AccessCode;
use Mojo::Base -base;

use Bytes::Random::Secure qw(random_string_from);

use CtrlNest::Helper::Constants;

use Exporter 'import';
our @EXPORT = qw(
  generate_ac_unique_code
  process_access_code_db_creation
  validate_ac_expires_in
  validate_ac_is_reusable
  validate_ac_title
  validate_ac_type
);

################################################################################

# @brief Generates a unique 8-character string using a predefined set of 32
#   characters.
#
# @param
#
# @return
#   - A randomly generated 8-character string.
#
sub generate_ac_unique_code {
  return random_string_from(ACCESS_CODE_ALLOWED_CHARS, ACCESS_CODE_LENGTH);
}

################################################################################

# @brief Creates a new access code by converting client-provided data from a
#   human-readable format into a database-compatible format and inserting it.
#   This method assumes that the provided data is already validated.
#
# @param $self           - Mojolicious controller instance.
#        $ac_title       - The access code title received from the client.
#        $ac_expires_in  - The expiration duration received from the client.
#        $ac_type        - The access code type received from the client.
#        $ac_is_reusable - The access code reusability received from the client.
#
# @return
#   - A DBIx::Class::Row object if the access code is successfully created.
#   - undef if the creation fails.
#
sub process_access_code_db_creation {
  my ($self, $ac_title, $expires_in, $type, $is_reusable, $ac_created_by) = @_;

  # Generate the access unique code
  my $ac_code = generate_ac_unique_code();

  # Validate the access code' title
  return INVALID_PARAMS unless validate_ac_title($ac_title);

  # Validate and convert expiration string to integer (seconds)
  my $ac_expires_in = validate_ac_expires_in($expires_in);
  return INVALID_PARAMS unless $ac_expires_in != INVALID;

  # Validate and convert type from string to bitmask
  my $ac_type = validate_ac_type($type);
  return INVALID_PARAMS unless $ac_type != INVALID;

  # Validate and convert checkbox value to bit
  my $ac_is_reusable = validate_ac_is_reusable($is_reusable);
  return INVALID_PARAMS unless $ac_is_reusable != INVALID_CHECKBOX;

  # Create a new access code
  my $access_code
    = $self->db->resultset('AccessCode')
    ->create_new($ac_code, $ac_title, $ac_expires_in, $ac_type, $ac_is_reusable,
    $ac_created_by);

  # The access code must exist
  return undef unless defined $access_code;

  return $access_code;    # Success
}

################################################################################

# @brief Validates the access code expiration duration by checking it against
#   defined constraints. Also, if the parameter is valid, it will be converted
#   from a human-readable format to seconds (integer).
#
# @param $access_code_expires_in - The human-readable expiration duration
#   (e.g., '30m', '7d', 'never', etc).
#
# @return
#   - The corresponding ACCESS_CODE_EXPIRES_IN_X_SECONDS constant, if valid.
#   - 0 (INVALID) if the expiration duration is invalid.
#
sub validate_ac_expires_in {
  my ($access_code_expires_in) = @_;

  # Must be defined
  return INVALID unless defined $access_code_expires_in;

  # Expires in 10m
  return ACCESS_CODE_EXPIRES_IN_10_MIN_SECONDS
    if ($access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_10_MIN);

  # Expires in 30m
  return ACCESS_CODE_EXPIRES_IN_30_MIN_SECONDS
    if ($access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_30_MIN);

  # Expires in 60m
  return ACCESS_CODE_EXPIRES_IN_60_MIN_SECONDS
    if ($access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_60_MIN);

  # Expires in 1d
  return ACCESS_CODE_EXPIRES_IN_1_DAY_SECONDS
    if ($access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_1_DAY);

  # Expires in 7d
  return ACCESS_CODE_EXPIRES_IN_7_DAY_SECONDS
    if ($access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_7_DAY);

  # Expires in 30d
  return ACCESS_CODE_EXPIRES_IN_30_DAY_SECONDS
    if ($access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_30_DAY);

  # Expires in never
  return ACCESS_CODE_EXPIRES_IN_NEVER_SECONDS
    if ($access_code_expires_in eq ACCESS_CODE_EXPIRES_IN_NEVER);

  return INVALID;    # Fail
}

################################################################################

# @brief Validates an access code reusability by checking it against
#   defined constraints. Also, if the parameter is valid, it will be converted
#   from a human-readable format to bit.
#
# @param $access_code_is_reusable - The human-readable reusability value.
#
# @return
#   - 1 if the reusability is valid.
#   - 0 if the reusability is invalid.
#
sub validate_ac_is_reusable {
  my ($access_code_is_reusable) = @_;

  # Must be defined
  return INVALID_CHECKBOX unless defined $access_code_is_reusable;

  # Must be one of the defined constant value
  return INVALID_CHECKBOX
    unless ($access_code_is_reusable eq CHECKBOX_CHECKED)
    or ($access_code_is_reusable eq CHECKBOX_UNCHECKED);

  # Check if the data was sent correctly
  # but the checkbox was not checked
  return INVALID unless ($access_code_is_reusable eq CHECKBOX_CHECKED);

  return SUCCESS;    # Success
}

################################################################################

# @brief Validates an access code title by checking it against defined
#   constraints.
#
# @param $title - The access code title to be validated.
#
# @return
#   - 1 if the title is valid.
#   - 0 if the title is invalid.
#
sub validate_ac_title {
  my ($title) = @_;

  # Must be defined
  return INVALID unless defined $title;

  # Trim whitespace
  $title =~ s/^\s+|\s+$//g;

  # Minimum and maximum length
  return INVALID if length($title) < ACCESS_CODE_TITLE_MIN_LEN;
  return INVALID if length($title) > ACCESS_CODE_TITLE_MAX_LEN;

  return SUCCESS;    # Success
}

################################################################################

# @brief Validates an access code type by checking it against defined
#   constraints. Also, if the parameter is valid, it will be converted from a
#   human-readable format to bitmask.
#
# @param $access_code_type - The human-readable type value (e.g. '2fa').
#
# @return
#   - The corresponding ACCESS_CODE_TYPE_X_BITMASK constant if valid.
#   - 0 (INVALID) if the type is invalid.
#
sub validate_ac_type {
  my ($access_code_type) = @_;

  # Must be defined
  return INVALID unless defined $access_code_type;

  # All Rights Type
  return ACCESS_CODE_TYPE_ALL_RIGHTS_BITMASK
    if ($access_code_type eq ACCESS_CODE_TYPE_ALL_RIGHTS);

  # Register Type
  return ACCESS_CODE_TYPE_REGISTER_BITMASK
    if ($access_code_type eq ACCESS_CODE_TYPE_REGISTER);

  # 2FA Type
  return ACCESS_CODE_TYPE_2FA_BITMASK
    if ($access_code_type eq ACCESS_CODE_TYPE_2FA);

  return INVALID;    # Fail
}

################################################################################

1;
