use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use CtrlNest::Helper::Constants;
use CtrlNest::Validator::AccessCode;

use lib 't';
use util::common;
use util::init;

# Init Mojo & Schema
my ($t, $db) = init_tests();

################################################################################

subtest 'Test validate_ac_code() with edge cases' => sub {

  # Must be defined
  my $ac_code_validation = validate_ac_code(undef);
  is($ac_code_validation->{status}, INVALID);
  is($ac_code_validation->{error},  'Access code is required');

  # Must be exactly 8 characters
  $ac_code_validation = validate_ac_code('');
  is($ac_code_validation->{status}, INVALID);
  is($ac_code_validation->{error},
    'Access code must be exactly 8 characters long');

  $ac_code_validation = validate_ac_code('   ');
  is($ac_code_validation->{status}, INVALID);
  is($ac_code_validation->{error},
    'Access code must be exactly 8 characters long');

  $ac_code_validation = validate_ac_code('ABCDEFG');
  is($ac_code_validation->{status}, INVALID);
  is($ac_code_validation->{error},
    'Access code must be exactly 8 characters long');

  $ac_code_validation = validate_ac_code('ABCDEFGH2');
  is($ac_code_validation->{status}, INVALID);
  is($ac_code_validation->{error},
    'Access code must be exactly 8 characters long');

  # Must contain only allowed characters
  $ac_code_validation = validate_ac_code('abcdefgh');
  is($ac_code_validation->{status}, INVALID);
  is($ac_code_validation->{error},
        'Access code can only contain these '
      . 'characters: [ ABCDEFGHJKLMNPQRTUVWXYZ2346789 ]');

  $ac_code_validation = validate_ac_code('ABCDEFGI');    # 'I' is not allowed
  is($ac_code_validation->{status}, INVALID);
  is($ac_code_validation->{error},
        'Access code can only contain these '
      . 'characters: [ ABCDEFGHJKLMNPQRTUVWXYZ2346789 ]');

  $ac_code_validation = validate_ac_code('ABCDEFGO');    # 'O' is not allowed
  is($ac_code_validation->{status}, INVALID);
  is($ac_code_validation->{error},
        'Access code can only contain these '
      . 'characters: [ ABCDEFGHJKLMNPQRTUVWXYZ2346789 ]');

  $ac_code_validation = validate_ac_code('ABCDEFGS');    # 'S' is not allowed
  is($ac_code_validation->{status}, INVALID);
  is($ac_code_validation->{error},
        'Access code can only contain these '
      . 'characters: [ ABCDEFGHJKLMNPQRTUVWXYZ2346789 ]');

  $ac_code_validation = validate_ac_code('ABCDEFG0');    # '0' is not allowed
  is($ac_code_validation->{status}, INVALID);
  is($ac_code_validation->{error},
        'Access code can only contain these '
      . 'characters: [ ABCDEFGHJKLMNPQRTUVWXYZ2346789 ]');

  $ac_code_validation = validate_ac_code('ABCDEFG1');    # '1' is not allowed
  is($ac_code_validation->{status}, INVALID);
  is($ac_code_validation->{error},
        'Access code can only contain these '
      . 'characters: [ ABCDEFGHJKLMNPQRTUVWXYZ2346789 ]');

  $ac_code_validation = validate_ac_code('ABCDEFG5');    # '5' is not allowed
  is($ac_code_validation->{status}, INVALID);
  is($ac_code_validation->{error},
        'Access code can only contain these '
      . 'characters: [ ABCDEFGHJKLMNPQRTUVWXYZ2346789 ]');

  # Contains only allowed characters and is exactly 8 characters long
  $ac_code_validation = validate_ac_code(' ABCD2346');
  is($ac_code_validation->{status}, SUCCESS);
  is($ac_code_validation->{data},   'ABCD2346');
};

################################################################################

subtest 'Test validate_ac_expires_in() with edge cases' => sub {

  # Must be defined
  my $expires_in_validation = validate_ac_expires_in(undef);
  is($expires_in_validation->{status}, INVALID);
  is($expires_in_validation->{error},
    'Access code expiration duration is required');

  # Non-standard parameters
  $expires_in_validation = validate_ac_expires_in(601);
  is($expires_in_validation->{status}, INVALID);
  is($expires_in_validation->{error},
    'Invalid access code expiration duration');

  $expires_in_validation = validate_ac_expires_in(-600);
  is($expires_in_validation->{status}, INVALID);
  is($expires_in_validation->{error},
    'Invalid access code expiration duration');

  # Success tests
  $expires_in_validation = validate_ac_expires_in('600');
  is($expires_in_validation->{status}, SUCCESS);
  is($expires_in_validation->{data},   ACCESS_CODE_EXPIRES_IN_10_MIN);

  $expires_in_validation = validate_ac_expires_in(600);
  is($expires_in_validation->{status}, SUCCESS);
  is($expires_in_validation->{data},   ACCESS_CODE_EXPIRES_IN_10_MIN);

  $expires_in_validation = validate_ac_expires_in(1800);
  is($expires_in_validation->{status}, SUCCESS);
  is($expires_in_validation->{data},   ACCESS_CODE_EXPIRES_IN_30_MIN);

  $expires_in_validation = validate_ac_expires_in(3600);
  is($expires_in_validation->{status}, SUCCESS);
  is($expires_in_validation->{data},   ACCESS_CODE_EXPIRES_IN_60_MIN);

  $expires_in_validation = validate_ac_expires_in(86400);
  is($expires_in_validation->{status}, SUCCESS);
  is($expires_in_validation->{data},   ACCESS_CODE_EXPIRES_IN_1_DAY);

  $expires_in_validation = validate_ac_expires_in(604800);
  is($expires_in_validation->{status}, SUCCESS);
  is($expires_in_validation->{data},   ACCESS_CODE_EXPIRES_IN_7_DAY);

  $expires_in_validation = validate_ac_expires_in(2592000);
  is($expires_in_validation->{status}, SUCCESS);
  is($expires_in_validation->{data},   ACCESS_CODE_EXPIRES_IN_30_DAY);

  $expires_in_validation = validate_ac_expires_in(-1);
  is($expires_in_validation->{status}, SUCCESS);
  is($expires_in_validation->{data},   ACCESS_CODE_EXPIRES_IN_NEVER);
};

################################################################################

subtest 'Test validate_ac_is_reusable() with edge cases' => sub {

  # Undefined parameter means that the checkbox was not checked
  my $is_reusable_validation = validate_ac_is_reusable(undef);
  is($is_reusable_validation->{status}, INVALID);
  is($is_reusable_validation->{error},  'Access code reusability is required');

  # Must be the defined constant value
  $is_reusable_validation = validate_ac_is_reusable('');
  is($is_reusable_validation->{status}, INVALID);
  is($is_reusable_validation->{error}, 'Invalid access code reusability value');

  $is_reusable_validation = validate_ac_is_reusable('   ');
  is($is_reusable_validation->{status}, INVALID);
  is($is_reusable_validation->{error}, 'Invalid access code reusability value');

  $is_reusable_validation = validate_ac_is_reusable('on');
  is($is_reusable_validation->{status}, INVALID);
  is($is_reusable_validation->{error}, 'Invalid access code reusability value');

  $is_reusable_validation = validate_ac_is_reusable('off');
  is($is_reusable_validation->{status}, INVALID);
  is($is_reusable_validation->{error}, 'Invalid access code reusability value');

  $is_reusable_validation = validate_ac_is_reusable('is_reusable');
  is($is_reusable_validation->{status}, INVALID);
  is($is_reusable_validation->{error}, 'Invalid access code reusability value');

  $is_reusable_validation = validate_ac_is_reusable('is_not_reusable');
  is($is_reusable_validation->{status}, INVALID);
  is($is_reusable_validation->{error}, 'Invalid access code reusability value');

  # Success tests (invalid means 0, and success means 1)
  $is_reusable_validation = validate_ac_is_reusable(' unchecked');
  is($is_reusable_validation->{status}, SUCCESS);
  is($is_reusable_validation->{data},   0);

  $is_reusable_validation = validate_ac_is_reusable('checked ');
  is($is_reusable_validation->{status}, SUCCESS);
  is($is_reusable_validation->{data},   1);
};

################################################################################

subtest 'Test validate_ac_title() with edge cases' => sub {

  # Must be defined
  my $title_validation = validate_ac_title(undef);
  is($title_validation->{status}, INVALID);
  is($title_validation->{error},  'Access code title is required');

  # Must be at least 1 character
  $title_validation = validate_ac_title('');
  is($title_validation->{status}, INVALID);
  is($title_validation->{error},
        'Access code title must be at least '
      . ACCESS_CODE_TITLE_MIN_LEN
      . ' characters long');

  $title_validation = validate_ac_title(' ');
  is($title_validation->{status}, INVALID);
  is($title_validation->{error},
        'Access code title must be at least '
      . ACCESS_CODE_TITLE_MIN_LEN
      . ' characters long');

  # Must be at maximum 65 characters
  $title_validation = validate_ac_title('T' x 66);
  is($title_validation->{status}, INVALID);
  is($title_validation->{error},
        'Access code title must be at most '
      . ACCESS_CODE_TITLE_MAX_LEN
      . ' characters long');

  # Must contain only allowed characters
  $title_validation = validate_ac_title('Invalid_Title!');
  is($title_validation->{status}, INVALID);
  is($title_validation->{error},
    'Access code title can only contain letters, numbers and spaces');

  # Success tests
  $title_validation = validate_ac_title(' A');
  is($title_validation->{status}, SUCCESS);
  is($title_validation->{data},   'A');

  $title_validation = validate_ac_title('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789');
  is($title_validation->{status}, SUCCESS);
  is($title_validation->{data},   'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789');

  $title_validation = validate_ac_title(' Some Title ');
  is($title_validation->{status}, SUCCESS);
  is($title_validation->{data},   'Some Title');

  $title_validation = validate_ac_title('T' x 64);
  is($title_validation->{status}, SUCCESS);
  is($title_validation->{data},   'T' x 64);
};

################################################################################

subtest 'Test validate_ac_type() with edge cases' => sub {

  # Must be defined
  my $type_validation = validate_ac_type(undef);
  is($type_validation->{status}, INVALID);
  is($type_validation->{error},  'Access code type is required');

  # Non-standard parameters
  $type_validation = validate_ac_type(1 << 10);
  is($type_validation->{status}, INVALID);
  is($type_validation->{error},  'Invalid access code type value');

  $type_validation = validate_ac_type('1 << 1');
  is($type_validation->{status}, INVALID);
  is($type_validation->{error},  'Invalid access code type value');

  # Success tests
  $type_validation = validate_ac_type(1 << 0);
  is($type_validation->{status}, SUCCESS);
  is($type_validation->{data},   ACCESS_CODE_TYPE_ALL_RIGHTS);

  $type_validation = validate_ac_type(1 << 1);
  is($type_validation->{status}, SUCCESS);
  is($type_validation->{data},   ACCESS_CODE_TYPE_REGISTER);

  $type_validation = validate_ac_type(1 << 2);
  is($type_validation->{status}, SUCCESS);
  is($type_validation->{data},   ACCESS_CODE_TYPE_2FA);
};

################################################################################

done_testing();
