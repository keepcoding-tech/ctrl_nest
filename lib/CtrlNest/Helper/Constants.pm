package CtrlNest::Helper::Constants;

use Exporter 'import';
use constant {

  # General
  SUCCESS => 1,
  INVALID => 0,

  INVALID_PARAMS => 0xF0000001,
  SUCCESS_PARAMS => 0xF0000002,

  INVALID_CHECKBOX   => 0xF0000004,
  CHECKBOX_CHECKED   => 'checked',
  CHECKBOX_UNCHECKED => 'unchecked',

  # Access Code
  ACCESS_CODE_ALLOWED_CHARS => 'ABCDEFGHJKLMNPQRTUVWXYZ2346789',
  ACCESS_CODE_LENGTH        => 8,

  ACCESS_CODE_TITLE_MIN_LEN => 1,
  ACCESS_CODE_TITLE_MAX_LEN => 60,

  ACCESS_CODE_EXPIRES_IN_10_MIN         => '10m',
  ACCESS_CODE_EXPIRES_IN_30_MIN         => '30m',
  ACCESS_CODE_EXPIRES_IN_60_MIN         => '60m',
  ACCESS_CODE_EXPIRES_IN_1_DAY          => '1d',
  ACCESS_CODE_EXPIRES_IN_7_DAY          => '7d',
  ACCESS_CODE_EXPIRES_IN_30_DAY         => '30d',
  ACCESS_CODE_EXPIRES_IN_NEVER          => 'never',
  ACCESS_CODE_EXPIRES_IN_10_MIN_SECONDS => 600,
  ACCESS_CODE_EXPIRES_IN_30_MIN_SECONDS => 1800,
  ACCESS_CODE_EXPIRES_IN_60_MIN_SECONDS => 3600,
  ACCESS_CODE_EXPIRES_IN_1_DAY_SECONDS  => 86400,
  ACCESS_CODE_EXPIRES_IN_7_DAY_SECONDS  => 604800,
  ACCESS_CODE_EXPIRES_IN_30_DAY_SECONDS => 2592000,
  ACCESS_CODE_EXPIRES_IN_NEVER_SECONDS  => -1,

  ACCESS_CODE_TYPE_ALL_RIGHTS         => 'all_rights',
  ACCESS_CODE_TYPE_REGISTER           => 'register',
  ACCESS_CODE_TYPE_2FA                => '2fa',
  ACCESS_CODE_TYPE_ALL_RIGHTS_BITMASK => 1 << 0,
  ACCESS_CODE_TYPE_REGISTER_BITMASK   => 1 << 1,
  ACCESS_CODE_TYPE_2FA_BITMASK        => 1 << 2,

  # Auth
  USERNAME_MIN_LEN => 3,
  USERNAME_MAX_LEN => 24,

  PASSWORD_MIN_LEN  => 8,
  PASSWORD_MAX_LEN  => 71,
  PASSWORD_SUBTYPE  => '2b',
  PASSWORD_COST     => 12,
  PASSWORD_SALT_LEN => 16,

  # Session
  SESSION_TIMEOUT    => 3600,
  SESSION_NOT_FOUND  => 'session not found',
  MAX_LOGIN_ATTEMPTS => 3,

  # Users
  ROLE_SUDO  => 'sudo',
  ROLE_ADMIN => 'admin',
  ROLE_USER  => 'user',
};

################################################################################

# Automatically export all constants defined in this package
our @EXPORT = grep { defined &{"CtrlNest::Helper::Constants::$_"} }
  keys %CtrlNest::Helper::Constants::;

################################################################################

1;
