package ShipIt::Step::MakeDist;
use strict;
use base 'ShipIt::Step';
use File::Copy ();

sub init {
    my ($self, $conf) = @_;
    my $dir = $conf->value("MakeDist.destination") || "~/shipit-dist";
    $dir =~ s/^~/$ENV{HOME}/;
    unless (-e $dir) {
        mkdir $dir or die "Failed to mkdir $dir: $!\n";
    }
    die "Config value of MakeDist.destination isn't a directory" unless -d $dir;
    $self->{distdir} = $dir;
}

sub run {
    my ($self, $state) = @_;
    my $pt   = $state->pt;
    my $file = $pt->makedist;

    if ($state->trial) {
        my $orig_file = $file;
        $file =~ s/\.(tar\.gz|tgz|tar.bz2|tbz|zip)$/-TRIAL.$1/
            or die "Distfile doesn't match supported archive format: $orig_file";
        warn "renaming $orig_file -> $file for TRIAL release\n";
        rename $orig_file, $file or die "Renaming $orig_file -> $file failed: $!";
    }

    File::Copy::move($file, $self->{distdir})
        or die "Moving distfile $file to $self->{distdir} failed: $!\n";

    $file =~ s!.*/!!; # keep only basename of file
    $file = "$self->{distdir}/$file";
    die "Distfile should be at $file but isn't.\n" unless -e $file;
    warn "Distfile now at $file\n";

    $state->set_distfile($file);
}

1;
