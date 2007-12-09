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

    # are they just compulsively running shipit?  i.e., they just asked for same
    # version as something tagged & no local diffs....
    if ($is_tagged && $newver eq $ver && ! $state->vc->are_local_diffs($ver)) {
        die "No local changes, and version on disk is already tagged.  Nothing to do.\n";
    }

    # check to make sure they're not releasing a version that's already tagged
    if ($state->vc->exists_tagged_version($newver)) {
        die "Sorry, version '$newver' is already tagged.  Stopping.\n";
    }

    $state->set_version($newver);
}

1;
