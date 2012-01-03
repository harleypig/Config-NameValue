
use Test::More tests => 12;
use Test::Deep;

BEGIN { use_ok( 'Config::NameValue' ) }

my $c = Config::NameValue->new( 't/test.config' );


