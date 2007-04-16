package ShipIt::Step::FindVersion;
use strict;
use base 'ShipIt::Step';
use ShipIt::Util qw($term);

# return if okay, die if problems.
sub run {
    my ($self, $state) = @_;
    my $ver = $state->pt->current_version;

    my $is_tagged = $state->vc->exists_tagged_version($ver);

    print "Current version is: $ver\n";
    my $def = "";

    # if the current version isn't tagged, use that as the default.  (they
    # probably already ran shipit and bumped the version, but perhaps
    # make dist or a test failed or something, so they're re-running it...)
    $def = "[$ver] " unless $is_tagged;

    my $newver = $term->readline("Next/release version? $def");
    $newver ||= $ver;

    # check to make sure they're not releasing a version that's already tagged
    if ($state->vc->exists_tagged_version($newver)) {
        die "Sorry, version '$newver' is already tagged.  Stopping.\n";
    }

    $state->set_version($newver);
}

1;
