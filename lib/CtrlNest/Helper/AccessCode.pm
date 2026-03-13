package CtrlNest::Helper::AccessCode;
use Mojo::Base -base;

use Bytes::Random::Secure qw(random_string_from);
use Time::Piece;

use CtrlNest::Helper::Constants;

use Exporter 'import';
our @EXPORT = qw(
  check_ac_availability
  generate_ac_unique_code
  process_access_code_db_creation
  validate_ac_code
  validate_ac_expires_in
  validate_ac_is_reusable
  validate_ac_title
  validate_ac_type
  validate_access_code
);

################################################################################

# @brief Checks the received timestamp of the access code plus the expiration
#        time and compares it against the current time.
#
# @param created_at  - The timestamp of the access code.
#        expires_in  - The number of seconds until it expires.
#        is_expired  - Bit value, checks if the access code had been used.
#        is_reusable - Bit value, checks if the access code is reusable.
#
# @return
#   - 1 (SUCCESS) if the code is still valid.
#   - 0 (INVALID) if the code is no longer valid.
#
sub check_ac_availability {
  my ($created_at, $expires_in, $is_expired, $is_reusable) = @_;

  # Default to non-reusable if not provided
  $is_reusable //= INVALID;

  # Return imediatelly if already expired
  return INVALID if $is_expired;

  return SUCCESS if $expires_in == ACCESS_CODE_EXPIRES_IN_NEVER_SECONDS;

  $created_at =~ s/\.\d+//;    # remove microseconds

  # add timezone minutes too if not included
  # e.g. "2024-06-01 12:00:00+02" -> "2024-06-01 12:00:00+0200"
  unless ($created_at =~ /[+-]\d{4}$/) {
    $created_at .= '00';
  }

  # Format and extract the timestamp
  my $t = Time::Piece->strptime($created_at, "%Y-%m-%d %H:%M:%S%z");

  return SUCCESS unless time() > ($t->epoch + $expires_in);

  return SUCCESS unless $is_reusable == INVALID;

  return INVALID;
}

################################################################################

# @brief Generates a unique 8-character string using a predefined set of 32
#        characters.
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
#   This method will also validate the provided data.
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
  my ($self, $ac_title, $type, $expires_in, $is_reusable, $ac_created_by) = @_;

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
    ->create_new($ac_code, $ac_title, $ac_type, $ac_expires_in, $ac_is_reusable,
    $ac_created_by);

  # The access code must exist
  return undef unless defined $access_code;

  return $access_code;    # Success
}

################################################################################

# @brief Validates the access code' unique code by checking it against
#   defined constraints.
#
# @param $code - The access code' unique code provided by the client.
#
# @return
#   - 1 (SUCCESS) if valid.
#   - 0 (INVALID) if invalid.
#
sub validate_ac_code {
  my ($code) = @_;

  # The code must exist
  return INVALID unless defined $code;

  # Must be exactly 8 characters
  return INVALID unless length($code) == ACCESS_CODE_LENGTH;

  # The code must contain only allowd characters
  return INVALID unless $code =~ /^[@{[ACCESS_CODE_ALLOWED_CHARS]}]+$/;

  return SUCCESS;
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

# @brief Validates an access code by checking its type and availability.
#        The type is validated against a required type provided as a parameter.
#        The availability is checked by verifying that the access code has not
#        expired and has not been used if it is non-re usable.
#
# @param $access_code   - The access code object to be validated.
#        $required_type - The required type that the access code must match.
#
# @return
#   - 1 (SUCCESS) if the access code is valid.
#   - 0 (INVALID) if the access code is invalid.
#
sub validate_access_code {
  my ($access_code, $required_type) = @_;

  return INVALID unless defined $access_code;
  return INVALID unless defined $required_type;

  return INVALID
    unless $access_code->{type} == $required_type
    || $access_code->{type} == ACCESS_CODE_TYPE_ALL_RIGHTS_BITMASK;

  return INVALID
    unless check_ac_availability(
    $access_code->{created_at},
    $access_code->{expires_in},
    $access_code->{is_expired}
    );

  return SUCCESS;    # Success
}

################################################################################

1;
