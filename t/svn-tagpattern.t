#!/usr/bin/perl
use strict;
use Test::More tests => 4;
use ShipIt::VC::SVN;

my $vc;

# trunk + relative
$vc = bless {
    url        => "http://code.example.com/svn/trunk/",
    tagpattern => 'Foo-%v',
}, "ShipIt::VC::SVN";
is($vc->_tag_url_of_version("0.25"), "http://code.example.com/svn/tags/Foo-0.25");

# no trailing trunk slash + relative
$vc = bless {
    url        => "http://code.example.com/svn/trunk",
    tagpattern => 'Foo-%v',
}, "ShipIt::VC::SVN";
is($vc->_tag_url_of_version("0.25"), "http://code.example.com/svn/tags/Foo-0.25");

# abs tag url, with pattern
$vc = bless {
    url        => "http://code.example.com/svn/trunk/",
    tagpattern => 'http://code.example.com/svn/mytags/Foo-%v',
}, "ShipIt::VC::SVN";
is($vc->_tag_url_of_version("0.25"), "http://code.example.com/svn/mytags/Foo-0.25");

# nothing
$vc = bless {
    url        => "http://code.example.com/svn/trunk/",
}, "ShipIt::VC::SVN";
is($vc->_tag_url_of_version("0.25"), "http://code.example.com/svn/tags/0.25");




