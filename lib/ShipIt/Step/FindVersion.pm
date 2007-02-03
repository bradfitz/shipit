package ShipIt::Step::FindVersion;
use strict;
use base 'ShipIt::Step';

# return if okay, die if problems.
sub run {
    my ($self, $state) = @_;
    warn "finding version!\n";
    my $ver = $state->pt->current_version;
    warn "current version = $ver\n";
}

1;
