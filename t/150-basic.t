
use Test::Most tests => 12;

BEGIN { use_ok( 'Config::NameValue' ) }

my $c = Config::NameValue->new( 't/test.config' );


