package CtrlNest::Validator::Pagination;
use Mojo::Base -base;

use CtrlNest::Helper::Constants;

use Exporter 'import';
our @EXPORT = qw(
  validate_page_number
  validate_search_keyword
);

################################################################################

# @brief Validates a page parameter to make sure is valid number (int).
#
# @param page - The page parameter recived from the client.
#
sub validate_page_number {
  my ($page) = @_;

  # Must exist
  unless (defined $page) {
    return {
      status => INVALID,
      error  => 'Page number is required'
    };
  }

  # Must be a number
  unless ($page =~ PAGINATION_PAGE_NUMBER_ALLOWED_CHARS) {
    return {
      status => INVALID,
      error  => 'Page number can only contain digits'
    };
  }

  # Must be a positive number
  if ($page < PAGINATION_PAGE_NUMBER_MIN) {
    return {
      status => INVALID,
      error  => 'Page number must be greater than zero (> 0)'
    };
  }

  # Must be smaller than max int value
  if ($page > PAGINATION_PAGE_NUMBER_MAX) {
    return {
      status => INVALID,
      error  => 'Page number must be smaller than '
        . 'two billion (< 2,000,000,000)'
    };
  }

  return {
    status => SUCCESS,
    data   => $page
  };
}

################################################################################

# @brief Validates a keyword parameter to make sure is valid text.
#
# @param search_keyword - The keyword parameter recived from the client.
#
sub validate_search_keyword {
  my ($search_keyword) = @_;

  # Must exist
  unless (defined $search_keyword) {
    return {
      status => INVALID,
      error  => 'Search keyword is required'
    };
  }

  # Cannot contain null bytes
  if (index($search_keyword, "\0") != -1) {
    return {
      status => INVALID,
      error  => 'Search keyword cannot contain null bytes'
    };
  }

  # Trim whitespace
  $search_keyword =~ s/^\s+|\s+$//g;

  # The length must be under 65 characters
  if (length $search_keyword > PAGINATION_SEARCH_KEYWORD_MAX_LEN) {
    return {
      status => INVALID,
      error  => 'Search keyword must be less than '
        . PAGINATION_SEARCH_KEYWORD_MAX_LEN
        . ' characters'
    };
  }

  return {
    status => SUCCESS,
    data   => $search_keyword
  };
}

################################################################################

1;
