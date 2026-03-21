package CtrlNest::Helper::AccessCode;
use Mojo::Base -base;

use Bytes::Random::Secure qw(random_string_from);
use Time::Piece;

use CtrlNest::Helper::Constants;
use CtrlNest::Validator::AccessCode;

use Exporter 'import';
our @EXPORT = qw(
  check_ac_availability
  generate_ac_unique_code
  process_access_code_db_creation
  verify_access_code_validity
);

################################################################################

# @brief Checks the received timestamp of the access code plus the expiration
#        time and compares it against the current time.
#
# @param access_code - The DBIx::Row object from the database.
#
# @return
#   - 1 (SUCCESS) if the code is still valid.
#   - 0 (INVALID) if the code is no longer valid.
#
sub check_ac_availability {
  my ($access_code) = @_;

  # The access code must exist
  return INVALID unless defined $access_code;

  # Return imediatelly if already expired
  return INVALID if $access_code->is_expired;

  my $created_at = $access_code->created_at->epoch;
  my $expires_in = $access_code->expires_in;

  # Return success if the access code never expires
  return SUCCESS if $expires_in == ACCESS_CODE_EXPIRES_IN_NEVER;

  # Return success if there is sufficient time before expiration
  return SUCCESS if time() < $created_at + $expires_in;

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
  return random_string_from('ABCDEFGHJKLMNPQRTUVWXYZ2346789',
    ACCESS_CODE_LENGTH);
}

################################################################################

# @brief Creates a new access code by converting client-provided data from a
#        human-readable format into a database-compatible format and inserting
#        it. This method will also validate the provided data.
#
# @param $self           - Mojolicious controller instance.
#        $ac_title       - The access code title received from the client.
#        $ac_type        - The access code type received from the client.
#        $ac_expires_in  - The expiration duration received from the client.
#        $ac_is_reusable - The access code reusability received from the client.
#        $ac_created_by  - The user UID of the creator of the access code.
#
# @return
#   - A DBIx::Class::Row object if the access code is successfully created.
#   - The appropriate error message if the access code creation fails.
#
sub process_access_code_db_creation {
  my ($self, $ac_title, $ac_type, $ac_expires_in, $ac_is_reusable,
    $ac_created_by)
    = @_;

  # Validate parameter data

  my $title_validation = validate_ac_title($ac_title);
  return $title_validation
    unless $title_validation->{status} == SUCCESS;

  my $expires_in_validation = validate_ac_expires_in($ac_expires_in);
  return $expires_in_validation
    unless $expires_in_validation->{status} == SUCCESS;

  my $type_validation = validate_ac_type($ac_type);
  return $type_validation
    unless $type_validation->{status} == SUCCESS;

  my $is_reusable_validation = validate_ac_is_reusable($ac_is_reusable);
  return $is_reusable_validation
    unless $is_reusable_validation->{status} == SUCCESS;

  # Create a new access code
  my $access_code = $self->db->resultset('AccessCode')->create_new(
    generate_ac_unique_code(),       $title_validation->{data},
    $type_validation->{data},        $expires_in_validation->{data},
    $is_reusable_validation->{data}, $ac_created_by
  );

  # The access code must exist
  unless (defined $access_code) {
    return {
      status => INVALID,
      error  => 'Internal server error'
    };
  }

  return {
    status => SUCCESS,
    data   => $access_code
  };
}

################################################################################

# @brief Validates the access code by checking its format, existence in the
#        database, type, and availability.
#
# @param $self          - Mojolicious controller instance.
#        $code          - The access code string received from the client.
#        $required_type - The required access code type for the intended action.
#
# @return
#   - 1 (SUCCESS) if the access code is valid.
#   - An error message if the validation fails.
#
sub verify_access_code_validity {
  my ($self, $code, $required_type) = @_;

  # Validate the access code format
  my $ac_code_validation = validate_ac_code($code);
  return $ac_code_validation
    unless $ac_code_validation->{status} == SUCCESS;

  my $ac_type_validation = validate_ac_type($required_type);
  return $ac_type_validation
    unless $ac_type_validation->{status} == SUCCESS;

  # Search for the access code in the database
  my $access_code = $self->db->resultset('AccessCode')->get_by_code($code);

  unless (defined $access_code) {
    return {
      status => INVALID,
      error  => 'Access code not found'
    };
  }

  # Check access code type
  if ( $access_code->type != $required_type
    && $access_code->type != ACCESS_CODE_TYPE_ALL_RIGHTS)
  {
    return {
      status => INVALID,
      error  => 'Access code type mismatch'
    };
  }

  # Check if the access code is available for registration
  if (check_ac_availability($access_code) == INVALID) {
    return {
      status => INVALID,
      error  => 'Access code has expired'
    };
  }

  return {
    status => SUCCESS,
    data   => $access_code
  };
}

################################################################################

1;
