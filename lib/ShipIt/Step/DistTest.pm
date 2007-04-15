package ShipIt::Step::DistTest;
use strict;
use base 'ShipIt::Step';

sub run {
    my ($self, $state) = @_;
    my $pt = $state->pt;
    die "Making dist & testing failed." unless $pt->disttest;
}

1;
