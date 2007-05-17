package ShipIt::Step::ChangeRPMVersion;
use strict;
use base 'ShipIt::Step';
use ShipIt::Util qw(slurp write_file);

sub run {
    my ($self, $state) = @_;

    my $version = $state->version;

    my @specfiles = glob("*.spec");

    die "Unable to find specfile to update RPM version.\n"
        unless @specfiles;

    die "Expected exactly one specfile, instead found: " . join(', ', @specfiles) . ".\n"
        if (@specfiles > 1);

    my $file = shift @specfiles;

    my $contents = slurp($file);
    $contents =~ s/^(\s*version:\s*)[\d.]+\s*$/${1}$version/m
        or die "Couldn't modify RPM specfile version number.\n";

    $contents =~ s/^(\s*release:\s*)\d+\s*$/${1}1/m
        or die "Couldn't modify RPM specfile release number.\n";

    if ($state->dry_run) {
        warn "Dry-run option has stopped us from upgrading RPM specfile '$file'.\n";
        return 1;
    }

    write_file($file, $contents);
    return 1;
}

1;
