package ShipIt::ProjectType;
use strict;

sub new { bless {}, $_[0] }

# returns current on-disk version number, not yet incremented.
sub find_version {
    die "ABSTRACT find_version in $_[0]\n";
}

1;
