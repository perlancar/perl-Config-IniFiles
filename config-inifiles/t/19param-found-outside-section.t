#!/usr/bin/perl

# This script attempts to reproduce:
# https://rt.cpan.org/Ticket/Display.html?id=36584

# Written by Shlomi Fish.
# This file is licensed under the MIT/X11 License.

use strict;
use warnings;

use Test::More;

use Config::IniFiles;

eval "use File::Temp qw(tempfile)";

plan skip_all => "File::Temp required for testing" if $@;

plan tests => 7;

{
    my ($fh, $filename) = tempfile();
    my $data = join "", <DATA>;
    open F, ">$filename";
    print F $data;
    close F;

    my $ini = Config::IniFiles->new(-file => $filename);

    # TEST
    ok(!defined($ini), "Ini was not initialised");

    # TEST
    is (scalar(@Config::IniFiles::errors), 1,
        "There is one error."
    );

    # TEST
    like ($Config::IniFiles::errors[0],
        qr/parameter found outside a section/,
        "Error was correct - 'parameter found outside a section'",
    );

    $ini = Config::IniFiles->new(-file => $filename, -fallback => 'GENERAL');

    # TEST
    ok(defined($ini), "(-fallback) Ini was initialised");

    # TEST
    ok($ini->SectionExists('GENERAL'), "(-fallback) Fallback section exists");

    # TEST
    ok($ini->exists('GENERAL', 'wrong'),
       "(-fallback) Fallback section catches parameter");
       
    # TEST
    my ($newfh, $newfilename) = tempfile();
    my $content;
    $ini->WriteConfig($newfilename);
    {
        local $/;
        open F, $newfilename;
        $content = <F>;
    }
    ok($content =~ /^wrong/m && $content !~ /^\[GENERAL\]/m,
       "(-fallback) Outputting fallback section without section header");
}

__DATA__

; This is a malformed ini file with a key/value outside a scrtion

wrong = wronger

[section]

right = more right

