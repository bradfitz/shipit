use strict;
use Test::More tests => 2;
use ShipIt::VC::SVK;

my $vc;

# trunk + relative
$vc = bless {
    url        => "//mirror/foo/trunk/",
    tagpattern => 'Foo-%v',
}, "ShipIt::VC::SVK";
is($vc->_tag_url_of_version("0.25"), "//mirror/foo/tags/Foo-0.25");

# absolute
$vc = bless {
    url        => "//mirror/foo/trunk",
    tagpattern => '//mirror/foo/tags/Foo-%v',
}, "ShipIt::VC::SVK";
is($vc->_tag_url_of_version("0.25"), "//mirror/foo/tags/Foo-0.25");
