use strict;
use warnings;

use Test::More;
use ShipIt::ProjectType::Perl;
use File::Spec::Functions qw(catfile);
use ShipIt::Util qw(slurp write_file);
use File::Copy;

my $proj = ShipIt::ProjectType::Perl->new();
ok($proj);

my $basedir = catfile(qw(t data Perl));

for my $filenum ( 1 .. 7 ) {
    my $origfile = catfile( $basedir, sprintf( '%02d.pm', $filenum ) );

    # check we read in the version correctly
    $proj->{ver_from} = $origfile;
    ok( $proj->version_from_file eq '1.005', "read version ($origfile)" );

    # now change the version, write it out,
    # read it back in and check it's right!
    $proj->{version} = $proj->version_from_file();
    copy( $origfile, "$origfile.new" );
    $proj->{ver_from} = "$origfile.new";

    # update with a normal number
    $proj->update_version('1.006');
    ok( $proj->version_from_file eq '1.006', "read new version ($origfile.new)" );
}

# cleanup
END {
    eval {
        for ( 1 .. 7 )
        {
            unlink catfile( $basedir, sprintf( '%02d.pm.new', $_ ) );
        }
    };
}

done_testing();
