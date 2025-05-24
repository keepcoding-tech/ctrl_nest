package CtrlNest::Helper::Constants;

use Exporter 'import';
use constant {

  # General
  SUCCESS => 1,
  INVALID => 0,

  # Users
  ROLE_SUDO  => 'sudo',
  ROLE_ADMIN => 'admin',
  ROLE_USER  => 'user',

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
};

################################################################################

# Automatically export all constants defined in this package
our @EXPORT = grep { defined &{"CtrlNest::Helper::Constants::$_"} }
  keys %CtrlNest::Helper::Constants::;

################################################################################

1;
