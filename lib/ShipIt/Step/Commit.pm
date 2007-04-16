package ShipIt::Step::Commit;
use strict;
use base 'ShipIt::Step';

sub run {
    my ($self, $state) = @_;
    my $vc  = $state->vc;
    my $ver = $state->version;

    my $msg = "Checking in changes prior to tagging of version $ver.  Changelog diff is:\n\n";

    foreach my $f ($state->changelog_files) {
        $msg .= $vc->local_diff($f);
    }

    if ($state->dry_run) {
        print "DRY-RUN.  Would have committed message of:\n----------------\n$msg\n-----------\n";
        return;
    }

    $vc->commit($msg);

}

1;
