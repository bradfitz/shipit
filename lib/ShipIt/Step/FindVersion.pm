package ShipIt::Step::FindVersion;
use strict;
use base 'ShipIt::Step';
use ShipIt::Util qw($term);

# return if okay, die if problems.
sub run {
    my ($self, $state) = @_;
    my $ver = $state->pt->current_version;

    my $is_tagged = $state->vc->exists_tagged_version($ver);

    print "Current version is: $ver (is_tagged=$is_tagged)\n";
    my $newver = $term->readline("Next/release version? ")
        or die "Aborted.\n";
    $state->set_version($newver);

}

1;
