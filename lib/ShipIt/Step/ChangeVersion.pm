package ShipIt::Step::ChangeVersion;
use strict;
use base 'ShipIt::Step';

sub run {
    my ($self, $state) = @_;
    $state->pt->update_version($state->version)
        or die "Failed to update version on disk\n";
}

1;
