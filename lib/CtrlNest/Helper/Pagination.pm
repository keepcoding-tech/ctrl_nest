package CtrlNest::Helper::Pagination;
use Mojo::Base -base;

use CtrlNest::Helper::Constants;

use Exporter 'import';
our @EXPORT = qw(
  get_pagination
  validate_page_number
  validate_search_keyword
);

################################################################################

# @brief Calculates the total number of pages for a given list.
#
# @param pager         - The DBIx::Class::ResultSet::Pager of the list.
#        page          - The current page of the list.
#        entries_limit - The maximum number of entries in the list (default 10).
#
# @return
#   - An object that incapsulates: the current page, the start and end of the
#     pagination, and the total number of pages.
#
sub get_pagination {
  my ($pager, $page, $entries_limit) = @_;

  # Default to 10
  $entries_limit //= 10;

  # Calculate the total number of pages
  my $total_entries = $pager->total_entries;
  my $total_pages = int(($total_entries + $entries_limit - 1) / $entries_limit);

  # 1 page before + 1 after = 3 total
  my $start = $page - 1;
  my $end   = $page + 1;

  $start = 1            if $start < 1;
  $end   = $total_pages if $end > $total_pages;

  # Adjust if near edges
  if ($end - $start < 2) {
    if ($start == 1) {
      $end = 3 if $total_pages >= 3;
    }
    elsif ($end == $total_pages) {
      $start = $total_pages - 2 if $total_pages >= 3;
    }
  }

  return {
    current => $page,
    start   => $start,
    end     => $end,
    total   => $total_pages
  };
}

################################################################################

# @brief Validates a page parameter to make sure is valid.
#
# @param page - The page parameter recived from the client.
#
# @return
#   - 1 if the page is valid.
#   - 0 if the page is invalid.
#
sub validate_page_number {
  my ($page) = @_;

  # Must exist
  return INVALID unless defined $page;

  # Must be a number
  return INVALID unless $page =~ /^\d+$/;

  # Must be a positive number
  return INVALID unless $page > 0;

  # Must be smaller than max int value
  return INVALID unless $page < 2_147_483_646;

  return SUCCESS;
}

################################################################################

# @brief Validates a keyword parameter to make sure is valid.
#
# @param search_keyword - The keyword parameter recived from the client.
#
# @return
#   - 1 if the page is valid.
#   - 0 if the page is invalid.
#
sub validate_search_keyword {
  my ($search_keyword) = @_;

  # Must exist
  return INVALID unless defined $search_keyword;

  # The length must be under 50 characters
  return INVALID unless length $search_keyword < 50;

  return SUCCESS;
}

################################################################################
