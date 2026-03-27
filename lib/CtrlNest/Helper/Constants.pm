package CtrlNest::Helper::Constants;

use Exporter 'import';
use constant {

  ##############################################################################
  ### Version
  ##############################################################################

  VERSION_NUMBER => 'v1.0.0',
  VERSION_NAME   => 'Snowflake',

  ##############################################################################
  ### General
  ##############################################################################

  SUCCESS => 1,
  INVALID => 0,

  INVALID_PARAMS => 0xF0000001,
  SUCCESS_PARAMS => 0xF0000002,

  CHECKBOX_CHECKED   => 'checked',
  CHECKBOX_UNCHECKED => 'unchecked',

  SESSION_TIMEOUT   => 3600,                  # 1 hour
  SESSION_NOT_FOUND => 'session not found',

  ##############################################################################
  ### Access Code
  ##############################################################################

  ACCESS_CODE_ALLOWED_CHARS => qr/^[ABCDEFGHJKLMNPQRTUVWXYZ2346789]+$/,
  ACCESS_CODE_LENGTH        => 8,

  ACCESS_CODE_TITLE_ALLOWED_CHARS => qr/^[A-Za-z0-9 ]+$/,
  ACCESS_CODE_TITLE_MIN_LEN       => 1,
  ACCESS_CODE_TITLE_MAX_LEN       => 64,

  ACCESS_CODE_TYPE_ALL_RIGHTS => 1 << 0,
  ACCESS_CODE_TYPE_REGISTER   => 1 << 1,
  ACCESS_CODE_TYPE_2FA        => 1 << 2,

  ACCESS_CODE_EXPIRES_IN_10_MIN => 600,
  ACCESS_CODE_EXPIRES_IN_30_MIN => 1800,
  ACCESS_CODE_EXPIRES_IN_60_MIN => 3600,
  ACCESS_CODE_EXPIRES_IN_1_DAY  => 86400,
  ACCESS_CODE_EXPIRES_IN_7_DAY  => 604800,
  ACCESS_CODE_EXPIRES_IN_30_DAY => 2592000,
  ACCESS_CODE_EXPIRES_IN_NEVER  => -1,

  ##############################################################################
  ### Pagination
  ##############################################################################


  PAGINATION_PAGE_NUMBER_ALLOWED_CHARS => qr/^[0-9]+$/,
  PAGINATION_PAGE_NUMBER_MIN           => 1,
  PAGINATION_PAGE_NUMBER_MAX           => 2_000_000_000,

  PAGINATION_SEARCH_KEYWORD_MAX_LEN => 65,

  ##############################################################################
  ### User
  ##############################################################################

  USER_USERNAME_ALLOWED_CHARS => qr/^[A-Za-z0-9_-]+$/,
  USER_USERNAME_MIN_LEN       => 3,
  USER_USERNAME_MAX_LEN       => 64,

  USER_EMAIL_ALLOWED_FORMAT =>
    qr/^[A-Za-z0-9._%+-]+@(?!-)[A-Za-z0-9.-]*[A-Za-z0-9]\.[A-Za-z]{2,}$/,
  USER_EMAIL_MIN_LEN => 5,
  USER_EMAIL_MAX_LEN => 256,

  USER_PASSWORD_ALLOWED_CHARS => qr/^[A-Za-z0-9!@#\$%\^&\*-]+$/,
  USER_PASSWORD_MIN_LEN       => 8,
  USER_PASSWORD_MAX_LEN       => 71,
  USER_PASSWORD_SUBTYPE       => '2b',
  USER_PASSWORD_COST          => 12,
  USER_PASSWORD_SALT_LEN      => 16,

  USER_FIRST_NAME_ALLOWED_CHARS => qr/^[A-Za-z]+$/,
  USER_FIRST_NAME_MIN_LEN       => 1,
  USER_FIRST_NAME_MAX_LEN       => 64,
  USER_LAST_NAME_ALLOWED_CHARS  => qr/^[A-Za-z -]+$/,
  USER_LAST_NAME_MIN_LEN        => 1,
  USER_LAST_NAME_MAX_LEN        => 64,

  USER_ROLE_SUDO  => 'sudo',
  USER_ROLE_ADMIN => 'admin',
  USER_ROLE_USER  => 'user'
};

################################################################################

# Automatically export all constants defined in this package
our @EXPORT = grep { defined &{"CtrlNest::Helper::Constants::$_"} }
  keys %CtrlNest::Helper::Constants::;

################################################################################

1;
