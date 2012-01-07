
# These tests were created to satisfy Devel::Cover reports.  They are not
# exhaustive and should not be considered as a complete test case.

use Test::Most tests => 25;
use Test::NoWarnings; # use ':early' to debug test

BEGIN { use_ok( 'Config::NameValue' ) }

throws_ok { $c->save } qr/No file to save/, 'caught bad save attempt';
is( Config::NameValue::error(), undef, 'error is empty' );

throws_ok { $c->get  } qr/Nothing loaded/,  'caught bad get attempt';
is( Config::NameValue::error(), undef, 'error is empty' );

throws_ok { $c->set  } qr/Nothing loaded/,  'caught bad set attempt';
is( Config::NameValue::error(), undef, 'error is empty' );

my $bad_filename = 'why do you have a file named like this?';
throws_ok { $c->load( $bad_filename ) } qr/read_file '\Q$bad_filename\E' - sysopen: No such file or directory/, 'bad filename caught';
is( Config::NameValue::error(), undef, 'error is empty' );
