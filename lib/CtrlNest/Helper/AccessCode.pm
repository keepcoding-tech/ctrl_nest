package CtrlNest::Helper::AccessCode;
use Mojo::Base -base;

use DateTime;

use CtrlNest::Helper::Constants;

use Exporter 'import';
our @EXPORT = qw(
  check_access_code_integrity
  check_expiration_date
  normalize_access_codes
  validate_access_code
);

################################################################################

# @brief Validates an access code by checking it against defined constraints.
#
# @param access_code - The access code string to validate.
#
# @return
#   - 1 if the access code is valid.
#   - 0 if the access code is invalid.
#
sub check_access_code_integrity {
  my ($access_code) = @_;

  # Must be defined
  return INVALID unless defined $access_code;

  # Must not contain null bytes
  return INVALID unless defined $access_code =~ /\x00/;

  # Minimum and Maximum length
  return INVALID if length($access_code) < ACCESS_CODE_LEN;
  return INVALID if length($access_code) > ACCESS_CODE_LEN;

  # Check for only allowed characters
  return INVALID unless $access_code =~ /^[ABCDEFGHJKLMNPQRTUVWXYZ2346789]+$/;

  return SUCCESS;    # Success
}

################################################################################

# @brief Checks whether the given timestamp is earlier than the current datetime.
#
# @param expires_at - The timestamp retrieved from the database.
#
# @return
#   - INVALID if the timestamp is earlier than or equal to the current datetime.
#   - SUCCESS if the timestamp is later than the current datetime.
#
sub check_expiration_date {
  my ($expires_at) = @_;

  # Get the current date and time
  my $now = DateTime->now(time_zone => 'UTC');

  # Check the expiration timestamp
  # with the current date and time
  return INVALID if $expires_at < $now;

  return SUCCESS;    # Success
}

################################################################################

# @brief
#
# @param $access_codes
#
# @return
#   - INVALID if the access code does not exist or has expired.
#   - SUCCESS if the access code is valid.
#
sub normalize_access_codes {
  my (@access_codes) = @_;

  my @normalized_access_codes;

  for my $ac (@access_codes) {

    my $expires_in = { days => 0, hours => 24, min => 30 };

    my $normalized_access_code = {
      code       => $ac->code,
      code_name  => $ac->code_name,
      expires_in => $ac->expires_in,
      is_expired => $ac->is_expired,
      created_at => $ac->created_at
    };

    push @normalized_access_codes, $normalized_access_code;
  }

  return @normalized_access_codes;
}

################################################################################

# @brief Validates a specific access code.
#
# @param $self - Mojolicious controller instance.
#        $code - Access code received from the URL.
#
# @return
#   - INVALID if the access code does not exist or has expired.
#   - SUCCESS if the access code is valid.
#
sub validate_access_code {
  my ($self, $code) = @_;

  # Validate access code
  return INVALID unless check_access_code_integrity($code);

  # Get the access code object from the database
  my $access_code = $self->db->resultset('AccessCode')->get_by_code($code);

  # The access code must exist
  return INVALID unless defined $access_code;

  # Check if the code has expired
  return INVALID unless check_expiration_date($access_code->expires_at);

  return SUCCESS;    # Success
}

################################################################################

1;
