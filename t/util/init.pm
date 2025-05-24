package util::init;

use strict;
use warnings;

use Test::Mojo;
use Test::DBIx::Class
  -schema_class => 'CtrlNest::Schema',
  -traits       => 'Testpostgresql';

use Exporter 'import';
our @EXPORT = qw(init_tests);

################################################################################

# @brief Initializes the test environment with a temporary database.
#
# @return
#   - Test::Mojo instance initialized with the CtrlNest app.
#   - CtrlNest::Schema object connected to the test database.
#
sub init_tests {

  # Get the test schema from Test::DBIx::Class
  my $schema = Schema();

  # Set up Mojolicious app and inject test database schema
  my $t = Test::Mojo->new('CtrlNest');
  $t->app->helper(db => sub {$schema});

  # Return the Test::Mojo and DB
  return ($t, $schema);
}

################################################################################

1;
