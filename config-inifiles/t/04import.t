use strict;
use Test;
use Config::IniFiles;

BEGIN { plan tests => 4 }

my $ors = $\ || "\n";
my ($ini,$value);

# Get files from the 't' directory, portably
chdir('t') if ( -d 't' );

#
# Import tests added by JW/WADG
#

# test 1
# print "Import a file .................... ";
my $en = new Config::IniFiles( -file => 'en.ini' );
ok( $en );

# test 2
my $es;
ok( $es = new Config::IniFiles( -file => 'es.ini', -import => $en ) );


# test 3
# Imported values are good
my $en_sn = $en->val( 'x', 'ShortName' );
my $es_sn = $es->val( 'x', 'ShortName' );
my $en_ln = $en->val( 'x', 'LongName' );
my $es_ln = $es->val( 'x', 'LongName' );
my $en_dn = $en->val( 'm', 'DataName' );
my $es_dn = $es->val( 'm', 'DataName' );
ok( 
	($en_sn eq 'GENERAL') &&
	($es_sn eq 'GENERAL') &&
	($en_ln eq 'General Summary') &&
	($es_ln eq 'Resumen general') &&
	($en_dn eq 'Month') &&
	($es_dn eq 'Mes') &&
	1#
  );

# test 4
# Import another level
my $ca = new Config::IniFiles( -file => 'ca.ini', -import => $es );
ok( 
	($en_sn eq $ca->val( 'x', 'ShortName' )) &&
	($es_sn eq $ca->val( 'x', 'ShortName' )) &&
	($ca->val( 'x', 'LongName' ) eq 'Resum general') &&
	($ca->val( 'm', 'DataName' ) eq 'Mes') &&
	1#
  );

