
# These tests were created to satisfy Devel::Cover reports.  They are not
# exhaustive and should not be considered as a complete test case.

use Test::More tests => 12;
use Test::Exception;

BEGIN { use_ok( 'Config::NameValue' ) }

throws_ok { Config::NameValue::new } qr/Invalid call to new/, 'caught bad call to new';
throws_ok { Config::NameValue::load } qr/Can't call load as a non-blessed object/, 'caught non-object call to load';
throws_ok { Config::NameValue::save } qr/Can't call save as a non-blessed object/, 'caught non-object call to save';
throws_ok { Config::NameValue::get } qr/Can't call get as a non-blessed object/, 'caught non-object call to get';
throws_ok { Config::NameValue::set } qr/Can't call set as a non-blessed object/, 'caught non-object call to set';

$c = Config::NameValue->new;

ok( $c->isa( 'Config::NameValue' ), 'object created' );

throws_ok { $c->load } qr/No file to load/, 'caught bad load attempt';
throws_ok { $c->save } qr/No file to save/, 'caught bad save attempt';
throws_ok { $c->get  } qr/Nothing loaded/,  'caught bad get attempt';
throws_ok { $c->set  } qr/Nothing loaded/,  'caught bad set attempt';

my $bad_filename = 'why do you have a file named like this?';
throws_ok { $c->load( $bad_filename ) } qr/read_file '\Q$bad_filename\E' - sysopen: No such file or directory/, 'bad filename caught';
