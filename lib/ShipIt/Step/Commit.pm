package ShipIt::Step::Commit;
use strict;
use base 'ShipIt::Step';

sub run {
    my ($self, $state) = @_;
    my $vc  = $state->vc;
    my $ver = $state->version;

    my $msg = "Checking in changes prior to tagging of version $ver.  Changelog diff is:\n\n";

    $vc->commit($msg);

}

1;
