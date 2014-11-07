
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.09

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Config/NameValue.pm',
    't/00-check-deps.t',
    't/00-compile.t',
    't/00-compile/lib_Config_NameValue_pm.t',
    't/00-load.t',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/000-report-versions.t',
    't/100-basic.t',
    't/test.config',
    't/zzz-check-breaks.t'
);

notabs_ok($_) foreach @files;
done_testing;
