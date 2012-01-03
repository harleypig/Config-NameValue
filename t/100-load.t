
use Test::More tests => 2;
use Test::Deep;

BEGIN { use_ok( 'Config::NameValue' ) }

my $c = Config::NameValue->new;

ok( $c->isa( 'Config::NameValue' ), 'created object correctly' );
