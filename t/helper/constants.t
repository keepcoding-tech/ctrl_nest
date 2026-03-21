use Test::More;
use CtrlNest::Helper::Constants;

##############################################################################
### General
##############################################################################

is(SUCCESS, 1);
is(INVALID, 0);

is(INVALID_PARAMS, 0xF0000001);
is(SUCCESS_PARAMS, 0xF0000002);

is(CHECKBOX_CHECKED,   'checked');
is(CHECKBOX_UNCHECKED, 'unchecked');

is(SESSION_TIMEOUT,   3600);
is(SESSION_NOT_FOUND, 'session not found');

##############################################################################
### Access Code
##############################################################################

is(ACCESS_CODE_ALLOWED_CHARS, qr/^[ABCDEFGHJKLMNPQRTUVWXYZ2346789]+$/);
is(ACCESS_CODE_LENGTH,        8);

is(ACCESS_CODE_TITLE_ALLOWED_CHARS, qr/^[A-Za-z0-9 ]+$/);
is(ACCESS_CODE_TITLE_MIN_LEN,       1);
is(ACCESS_CODE_TITLE_MAX_LEN,       65);

is(ACCESS_CODE_TYPE_ALL_RIGHTS, 1 << 0);
is(ACCESS_CODE_TYPE_REGISTER,   1 << 1);
is(ACCESS_CODE_TYPE_2FA,        1 << 2);

is(ACCESS_CODE_EXPIRES_IN_10_MIN, 600);
is(ACCESS_CODE_EXPIRES_IN_30_MIN, 1800);
is(ACCESS_CODE_EXPIRES_IN_60_MIN, 3600);
is(ACCESS_CODE_EXPIRES_IN_1_DAY,  86400);
is(ACCESS_CODE_EXPIRES_IN_7_DAY,  604800);
is(ACCESS_CODE_EXPIRES_IN_30_DAY, 2592000);
is(ACCESS_CODE_EXPIRES_IN_NEVER,  -1);

##############################################################################
### Pagination
##############################################################################

is(PAGINATION_PAGE_NUMBER_ALLOWED_CHARS, qr/^[0-9]+$/);
is(PAGINATION_PAGE_NUMBER_MIN,           1);
is(PAGINATION_PAGE_NUMBER_MAX,           2_000_000_000);

is(PAGINATION_SEARCH_KEYWORD_MAX_LEN, 65);

##############################################################################
### User
##############################################################################

is(USER_FIRST_NAME_ALLOWED_CHARS, qr/^[A-Za-z]+$/);
is(USER_FIRST_NAME_MIN_LEN,       1);
is(USER_FIRST_NAME_MAX_LEN,       65);
is(USER_LAST_NAME_ALLOWED_CHARS,  qr/^[A-Za-z -]+$/);
is(USER_LAST_NAME_MIN_LEN,        1);
is(USER_LAST_NAME_MAX_LEN,        65);

is(USER_USERNAME_ALLOWED_CHARS, qr/^[A-Za-z0-9_-]+$/);
is(USER_USERNAME_MIN_LEN,       3);
is(USER_USERNAME_MAX_LEN,       24);

is(USER_EMAIL_ALLOWED_FORMAT,
  qr/^[A-Za-z0-9._%+-]+@(?!-)[A-Za-z0-9.-]*[A-Za-z0-9]\.[A-Za-z]{2,}$/);
is(USER_EMAIL_MIN_LEN, 5);
is(USER_EMAIL_MAX_LEN, 255);

is(USER_PASSWORD_ALLOWED_CHARS, qr/^[A-Za-z0-9!@#\$%\^&\*-]+$/);
is(USER_PASSWORD_MIN_LEN,       8);
is(USER_PASSWORD_MAX_LEN,       71);
is(USER_PASSWORD_SUBTYPE,       '2b');
is(USER_PASSWORD_COST,          12);
is(USER_PASSWORD_SALT_LEN,      16);

is(USER_ROLE_SUDO,  'sudo');
is(USER_ROLE_ADMIN, 'admin');
is(USER_ROLE_USER,  'user');

done_testing;
