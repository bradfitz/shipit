package ShipIt::ProjectType::Perl;
use strict;
use base 'ShipIt::ProjectType';

sub current_version {
    open (my $fh, "Makefile.PL") or die "Can't open Makefile.PL: $!\n";
    my $ver;
    my $ver_from;
    while (<$fh>) {
        if (/VERSION_FROM.+([\'\"])(.+?)\1/) {
            $ver_from = $2;
            last;
        }
    }
    close($fh);
    die "No VERSION_FROM or VERSION\n" unless $ver || $ver_from;
    warn "ver_from=[$ver_from], ver=[$ver]\n";
}


1;
