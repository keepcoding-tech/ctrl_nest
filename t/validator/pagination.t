use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use CtrlNest::Helper::Constants;
use CtrlNest::Validator::Pagination;

use lib 't';
use util::common;
use util::init;

# Init Mojo & Schema
my ($t, $db) = init_tests();

################################################################################

subtest 'Test validate_page_number() with edge cases' => sub {

  # Must be defined
  my $page_number_validation = validate_page_number(undef);
  is($page_number_validation->{status}, INVALID);
  is($page_number_validation->{error},  'Page number is required');

  # Must be a number
  $page_number_validation = validate_page_number('abc');
  is($page_number_validation->{status}, INVALID);
  is($page_number_validation->{error},  'Page number can only contain digits');

  # Must be a positive number
  $page_number_validation = validate_page_number(0);
  is($page_number_validation->{status}, INVALID);
  is($page_number_validation->{error},
    'Page number must be greater than zero (> 0)');

  # Must be smaller than max int value
  $page_number_validation = validate_page_number(2_000_000_001);
  is($page_number_validation->{status}, INVALID);
  is($page_number_validation->{error},
    'Page number must be smaller than two billion (< 2,000,000,000)');

  # Valid page number
  $page_number_validation = validate_page_number(1);
  is($page_number_validation->{status}, SUCCESS);
  is($page_number_validation->{data},   1);

  $page_number_validation = validate_page_number('100');
  is($page_number_validation->{status}, SUCCESS);
  is($page_number_validation->{data},   100);
};

################################################################################

subtest 'Test validate_search_keyword() with edge cases' => sub {

  # Must be defined
  my $search_keyword_validation = validate_search_keyword(undef);
  is($search_keyword_validation->{status}, INVALID);
  is($search_keyword_validation->{error},  'Search keyword is required');

  # Cannot contain null bytes
  $search_keyword_validation = validate_search_keyword("abc\0def");
  is($search_keyword_validation->{status}, INVALID);
  is($search_keyword_validation->{error},
    'Search keyword cannot contain ' . 'null bytes');

  # The length must be under 65 characters
  $search_keyword_validation = validate_search_keyword('a' x 66);
  is($search_keyword_validation->{status}, INVALID);
  is($search_keyword_validation->{error},
        'Search keyword must be less than '
      . PAGINATION_SEARCH_KEYWORD_MAX_LEN
      . ' characters');

  # Valid search keyword
  $search_keyword_validation = validate_search_keyword(' example ');
  is($search_keyword_validation->{status}, SUCCESS);
  is($search_keyword_validation->{data},   'example');
};

################################################################################

done_testing();
