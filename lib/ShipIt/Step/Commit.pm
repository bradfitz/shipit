package ShipIt::Step::Commit;
use strict;
use base 'ShipIt::Step';

sub run {
    my ($self, $state) = @_;

    my $vc = $state->vc;
    $vc->commit("Auto-commit for version " . $state->version);
}

1;
