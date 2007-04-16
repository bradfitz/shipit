package ShipIt::Step::Tag;
use strict;
use base 'ShipIt::Step';

sub run {
    my ($self, $state) = @_;
    my $ver = $state->version;
    $state->vc->tag_version($ver, "Tagging version '$ver' using shipit.");
}

1;
