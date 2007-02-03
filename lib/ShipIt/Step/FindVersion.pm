package ShipIt::Step::FindVersion;
use strict;
use base 'ShipIt::Step';

sub init {
    my ($self, $conf) = @_;
    if (-e "Makefile.PL") {
        bless $self, "ShipIt::Step::FindVersion::Perl";
    } else {
        die "Unknown project type; can't find version.\n";
    }
}

# return if okay, die if problems.
sub run {
    my ($self, $state) = @_;
    warn "finding version!\n";
}

1;
