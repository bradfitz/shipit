package ShipIt::Step::DistTest;
use strict;
use base 'ShipIt::Step';

sub run {
    my ($self, $state) = @_;
    my $pt = $state->pt;
    if ($state->skip_tests) {
        warn "\n**** ShipIt:  SKIPPING DIST TEST\n\n";
        return;
    }
    die "Making dist & testing failed." unless $pt->disttest;
}

1;
