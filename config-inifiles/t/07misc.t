use strict;
use Test;
use Config::IniFiles;

BEGIN { plan tests => 3 }

my ($ini, $value);

# Test 1
# Multiple equals in a parameter - should split on the first
$ini = new Config::IniFiles( -file => 't/test.ini' );
$value = $ini->val('test7', 'criterion') || '';
ok($value eq 'price <= maximum');

# Test 2
# Parameters whose name is a substring of existing parameters should be loaded
$value = $ini->val('substring', 'jacques');
ok( $value eq 'smarty');

# test 3 
# See if default option works
$ini = new Config::IniFiles( -file => "t/test.ini", -default => 'test1', -nocase => 1 );
$ini->SetFileName("t/test07.ini");
ok( (defined $ini) && ($ini->val('test2', 'three') eq 'value3') );

