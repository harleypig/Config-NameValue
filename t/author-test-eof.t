
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

use strict;
use warnings;
use Test::More;

# Generated by Dist::Zilla::Plugin::Test::EOF 0.03
use Test::EOF;

all_perl_files_ok({ minimum_newlines => 1, maximum_newlines => 4 });

done_testing();
