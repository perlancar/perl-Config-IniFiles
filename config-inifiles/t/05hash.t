use strict;
use Test;
use Config::IniFiles;

BEGIN { plan tests => 17 }

#
# Hash tying tests added by JW/WADG
#

my %ini;
my ($ini, $value);

# test 1
# print "Tying a hash ..................... ";
ok( tie %ini, 'Config::IniFiles', ( -file => "t/test.ini", -default => 'test1', -nocase => 1 ) );

# test 2
# print "Accessing a hash ................. ";
$value = $ini{test1}{one};
ok($value eq 'value1');

# test 3
# print "Creating through a hash .......... ";
$ini{'test2'}{'seven'} = 'value7';
tied(%ini)->RewriteConfig;
tied(%ini)->ReadConfig;
$value = $ini{'test2'}{'seven'};
ok($value eq 'value7');

# test 4
# print "Deleting through hash ............ ";
delete $ini{test2}{seven};
tied(%ini)->RewriteConfig;
tied(%ini)->ReadConfig;
$value='';
$value = $ini{test2}{seven};
ok(! defined ($value));

# test 5
# print "-default option in a hash ........ ";
ok( $ini{test2}{three} eq 'value3' );

# test 6
#print "Case insensitivity in a hash ..... ";
ok( $ini{TEST2}{THREE} eq 'value3' );

# test 7
# print "Listing sections ................. ";
$value = 1;
$ini = new Config::IniFiles( -file => "t/test.ini" );
my @S1 = $ini->Sections;
my @S2 = keys %ini;
foreach (@S1) {
	unless( (grep "$_", @S2) &&
	        (grep "$_", qw( test1 test2 [w]eird characters ) ) ) {
		$value = 0;
		last;
	}
}
ok( $value );

# test 8
# print "Listing parameters ............... ";
$value = 1;
@S1 = $ini->Parameters('test1');
@S2 = keys %{$ini{test1}};
foreach (@S1) {
	unless( (grep "$_", @S2) &&
	        (grep "$_", qw( three two one ) ) ) {
		$value = 0;
		last;
	}
}
ok($value);

# test 9
# print "Copying a section in a hash ...... ";
my %bak = %{$ini{test2}};
$value = $bak{six} || '';
ok( $value eq 'value6' );

# test 10
# print "Deleting a section in a hash ..... ";
delete $ini{test2};
$value = $ini{test2};
ok(not $value);

# test 11
# print "Setting a section in a hash ...... ";
$ini{newsect} = {};
%{$ini{newsect}} = %bak;
$value = $ini{newsect}{four} || '';
ok( $value eq 'value4' );

# test 12
# print "-default in new section in hash .. ";
$value = $ini{newsect}{one};
ok( $value eq 'value1' );

# test 13
# print "Store new section in hash ........ ";
tied(%ini)->RewriteConfig;
tied(%ini)->ReadConfig;
$value = $ini{newsect}{four} || '';
ok( $value eq 'value4' );
 
# test 14
# my %foo;
# print "Checking failure for missing ini (a failure message is normal here)\n";
# # if(!tie(%foo, 'Config::IniFiles', -file => "doesnotexist.ini") ) {
#	print "ok $t\n";
ok(1);
# } else {
#	print "not ok $t\n";
# }

# test 15
my ($n1, $n2, $n3);
# print "Sections/Parms for undef value ... ";
$n1 = tied(%ini)->Parameters( 'newsect' );
$ini{newsect}{four} = undef;
$n2 = tied(%ini)->Parameters( 'newsect' );
$ini{newsect}{four} = 'value4';
$n3 = tied(%ini)->Parameters( 'newsect' );
ok( $n1 == $n1 && $n2 == $n3 );

# test 16
# print "Sections/Parms for undef value ... ";
$n1 = tied(%ini)->Parameters( 'newsect' );
$ini{newsect}{four} = undef;
$n2 = tied(%ini)->Parameters( 'newsect' );
$ini{newsect}{four} = 'value4';
$n3 = tied(%ini)->Parameters( 'newsect' );
ok( $n1 == $n1 && $n2 == $n3 );


# test 17
# Writing 2 line multilvalue and returing it
$t++;
$ini{'test2'}{'multi_2'} = ['line 1', 'line 2'];
tied(%ini)->RewriteConfig;
tied(%ini)->ReadConfig;
@value = split( /[\$\n]/, $ini{'test2'}{'seven'} );;
ok(@value == 2 && $value[0] eq 'line1' && $value[1] eq 'line 2');


