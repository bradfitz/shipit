use strict;
use warnings;

use Test::More;
use ShipIt::ProjectType::Perl;
use File::Spec::Functions qw(catfile);
use ShipIt::Util qw(slurp write_file);
use File::Copy;

my $proj = ShipIt::ProjectType::Perl->new();
ok($proj);

# successful extractions
for my $set (
    [ q{our $VERSION = '0.02';},             q{our $VERSION = '0.02'} ],
    [ q{our $VERSION  =  0.03; # something}, q{our $VERSION  =  0.03} ],
    [ q{our $VERSION = qv("0.04"); # blah},  q{our $VERSION = qv("0.04")} ],
    [ q{our $VERSION = qv( '0.04' );},       q{our $VERSION = qv( '0.04' )} ],
    [ q{our $VERSION = qv('v0.05') ; },      q{our $VERSION = qv('v0.05')} ],
    [ q{our $VERSION = q(0.10);},            q{our $VERSION = q(0.10)} ],
    [ q{our $VERSION = qq(0.10);},           q{our $VERSION = qq(0.10)} ],
    [ q{our $VERSION = qq(0.10); $xxx = 1;}, q{our $VERSION = qq(0.10)} ],
    [ q{$xxx = 1; our $VERSION = qq(0.10);}, q{our $VERSION = qq(0.10)} ],
    [   q{use version; our $VERSION = qv('v1.5.0');},
        q{use version; our $VERSION = qv('v1.5.0')}
    ]
    )
{
    my $input    = $set->[0];
    my $got      = $proj->_versioncode_from_string($input);
    my $expected = $set->[1];

    ok( $got eq $expected, $input );

    #diag "Expected: $expected";
    #diag "     Got: $got";
}

# unsuccessful extractions
for my $input ( q{my $version = '0.01';}, q{our $version = '0.01';}, q{Version 0.03} ) {
    my $got = $proj->_versioncode_from_string($input);

    ok( $got == 0 );

    #diag "Expected: 0";
    #diag "     Got: $got";
}

done_testing();

