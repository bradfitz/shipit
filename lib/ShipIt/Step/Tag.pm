package ShipIt::Step::Tag;
use strict;
use base 'ShipIt::Step';

sub run {
    my ($self, $state) = @_;
    my $ver = $state->version;

    if ($state->dry_run) {
        print "DRY-RUN.  Would have tagged version $ver.\n";
        return;
    }

    $state->vc->tag_version($ver, "Tagging version '$ver' using shipit.");
}

1;
