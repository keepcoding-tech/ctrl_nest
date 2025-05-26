use Test::More;
use CtrlNest::Helper::Constants;

# General
is(SUCCESS, 1);
is(INVALID, 0);

# Users
is(ROLE_SUDO,  'sudo');
is(ROLE_ADMIN, 'admin');
is(ROLE_USER,  'user');

# Auth
is(USERNAME_MIN_LEN,  3);
is(USERNAME_MAX_LEN,  24);
is(PASSWORD_MIN_LEN,  8);
is(PASSWORD_MAX_LEN,  71);
is(PASSWORD_SUBTYPE,  '2b');
is(PASSWORD_COST,     12);
is(PASSWORD_SALT_LEN, 16);

# Session
is(SESSION_TIMEOUT,    3600);
is(MAX_LOGIN_ATTEMPTS, 3);

done_testing;
