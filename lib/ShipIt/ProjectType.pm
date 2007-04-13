package ShipIt::ProjectType;
use strict;

sub new { bless {}, $_[0] }

# returns current on-disk version number, not yet incremented.
sub find_version {
    die "ABSTRACT find_version in $_[0]\n";
}

# update version number on disk
sub update_version {
    my ($self, $newver) = @_;
    die "ABSTRACT update_version in $_[0]\n";
}

1;
