use strict;
use Test;
use Config::IniFiles;

BEGIN { plan tests => 22 }

my %ini;
my ($ini, $value);
my (@value);

# Test 1
# Tying a hash.
ok( tie %ini, 'Config::IniFiles', ( -file => "t/test.ini", -default => 'test1', -nocase => 1 ) );
tied(%ini)->SetFileName("t/test05.ini");

# Test 2
# Retrieve scalar value
$value = $ini{test1}{one};
ok($value eq 'value1');

# Test 3
# Retrieve array reference
$value = $ini{test1}{mult};
ok(ref $value eq 'ARRAY'); 

# Test 4
# Creating a scalar value using tied hash
$ini{'test2'}{'seven'} = 'value7';
tied(%ini)->RewriteConfig;
tied(%ini)->ReadConfig;
$value = $ini{'test2'}{'seven'};
ok($value eq 'value7');

# Test 5
# Deleting a scalar value using tied hash
delete $ini{test2}{seven};
tied(%ini)->RewriteConfig;
tied(%ini)->ReadConfig;
$value='';
$value = $ini{test2}{seven};
ok(! defined ($value));

# Test 6
# Testing default values using tied hash
ok( $ini{test2}{three} eq 'value3' );

# Test 7
# Case insensitivity in a hash parameter
ok( $ini{test2}{FOUR} eq 'value4' );

# Test 8
# Case insensitivity in a hash section
ok( $ini{TEST2}{four} eq 'value4' );

# Test 9
# Listing section names using keys
$value = 1;
$ini = new Config::IniFiles( -file => "t/test.ini" );
$ini->SetFileName("t/test05b.ini");
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

# Test 10
# Listing parameter names using keys
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

# Test 11
# Copying a section using tied hash
my %bak = %{$ini{test2}};
$value = $bak{six} || '';
ok( $value eq 'value6' );

# Test 12
# Deleting a whole section using tied hash
delete $ini{test2};
$value = $ini{test2};
ok(not $value);

# Test 13
# Creating a section and parameters using a hash
$ini{newsect} = {};
%{$ini{newsect}} = %bak;
$value = $ini{newsect}{four} || '';
ok( $value eq 'value4' );

# Test 14
# Checking use of default values for newly created section
$value = $ini{newsect}{one};
ok( $value eq 'value1' );

# Test 15
# print "Store new section in hash ........ ";
tied(%ini)->RewriteConfig;
tied(%ini)->ReadConfig;
$value = $ini{newsect}{four} || '';
ok( $value eq 'value4' );
 
# Test 16
# my %foo;
# print "Checking failure for missing ini (a failure message is normal here)\n";
# # if(!tie(%foo, 'Config::IniFiles', -file => "doesnotexist.ini") ) {
#	print "ok $t\n";
ok(1);
# } else {
#	print "not ok $t\n";
# }

# Test 17
my ($n1, $n2, $n3);
# print "Sections/Parms for undef value ... ";
$n1 = tied(%ini)->Parameters( 'newsect' );
$ini{newsect}{four} = undef;
$n2 = tied(%ini)->Parameters( 'newsect' );
$ini{newsect}{four} = 'value4';
$n3 = tied(%ini)->Parameters( 'newsect' );
ok( $n1 == $n1 && $n2 == $n3 );

# Test 18
# print "Sections/Parms for undef value ... ";
$n1 = tied(%ini)->Parameters( 'newsect' );
$ini{newsect}{four} = undef;
$n2 = tied(%ini)->Parameters( 'newsect' );
$ini{newsect}{four} = 'value4';
$n3 = tied(%ini)->Parameters( 'newsect' );
ok( $n1 == $n1 && $n2 == $n3 );


# Test 19
# Writing 2 line multilvalue and returing it
$ini{newsect} = {};
$ini{test1}{multi_2} = ['line 1', 'line 2'];
tied(%ini)->RewriteConfig;
tied(%ini)->ReadConfig;
@value = @{$ini{test1}{multi_2}};
ok( (@value == 2) 
    && ($value[0] eq 'line 1')
    && ($value[1] eq 'line 2')
  );

# Test 20
# Getting a default value not in the file
tie %ini, 'Config::IniFiles', ( -file => "t/test.ini", -default => 'default', -nocase => 1 );
$ini{default}{cassius} = 'clay';
$value = $ini{test1}{cassius};
ok( $value eq 'clay' );

# Test 21
# Setting value to number of elements in array
my @thing = ("one", "two", "three");
$ini{newsect}{five} = @thing;
$value = $ini{newsect}{five};
ok($value == 3);

# Test 22
# Setting value to number of elements in array
@thing = ("one");
$ini{newsect}{five} = @thing;
$value = $ini{newsect}{five};
ok($value == 1);
