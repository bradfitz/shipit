package ShipIt::Step::FindVersion;
use strict;
use base 'ShipIt::Step';
use Term::ReadLine;

our $term = Term::ReadLine->new("verprompt");

# return if okay, die if problems.
sub run {
    my ($self, $state) = @_;
    my $ver = $state->pt->current_version;
    print "Current version is: $ver\n";
    my $newver = $term->readline("Next/release version? ")
        or die "Aborted.\n";
    $state->set_version($newver);

}

1;
