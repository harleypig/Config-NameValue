use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::CheckBreaks 0.011

use Test::More 0.88;

SKIP: {
  {
    {
      if ( $module ) {
        require Module::Runtime;
        my $filename = Module::Runtime::module_notional_filename( $module );
        <<"CHECK_CONFLICTS";
    eval 'require $module; ${module}->check_conflicts';
    skip('no $module module found', 1) if not \$INC{'$filename'};

    diag \$@ if \$@;
    pass 'conflicts checked via $module';
CHECK_CONFLICTS
      } else {
        "    skip 'no conflicts module found to check against', 1;\n";
      }
    }
  }
} ## end SKIP:

{
  {
    if ( keys %$breaks ) {
      my $dumper = Data::Dumper->new( [ $breaks ], [ 'breaks' ] );
      $dumper->Sortkeys( 1 );
      $dumper->Indent( 1 );
      $dumper->Useqq( 1 );
      my $dist_name = $dist->name;
      'my ' . $dumper->Dump . <<'CHECK_BREAKS_1' .

use CPAN::Meta::Requirements;
my $reqs = CPAN::Meta::Requirements->new;
$reqs->add_string_requirement($_, $breaks->{$_}) foreach keys %$breaks;

use CPAN::Meta::Check 0.007 'check_requirements';
our $result = check_requirements($reqs, 'conflicts');

if (my @breaks = grep { defined $result->{$_} } keys %$result)
{
CHECK_BREAKS_1
        "    diag 'Breakages found with $dist_name:';\n" . <<'CHECK_BREAKS_2';
    diag "$result->{$_}" for sort @breaks;
    diag "\n", 'You should now update these modules!';
}
CHECK_BREAKS_2
    } else {
      q{pass 'no x_breaks data to check';} . "\n";
    }
  }
}
done_testing;
