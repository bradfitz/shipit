package ShipIt::Step::UploadCPAN;
use strict;
use base 'ShipIt::Step';
use ShipIt::Util qw(bool_prompt);
use File::Spec;

sub init {
    my ($self, $conf) = @_;
    my $exe = '';
    foreach my $dir (File::Spec->path) {
        $exe = 'cpan-upload-http';
        last if -x File::Spec->catfile($dir, $exe);
        $exe = 'cpan-upload';
        last if -x File::Spec->catfile($dir, $exe);
    }
    die "cpan-upload-http not found\n" unless $exe;
    $self->{exe} = $exe;
}

sub run {
    my ($self, $state) = @_;
    my $distfile =  $state->distfile;
    die "No distfile was created!"             unless $distfile;
    die "distfile $distfile no longer exists!" unless -e $distfile;

    if ($state->dry_run) {
        warn "*** DRY RUN, not uploading to CPAN!\n";
        return;
    }

    return unless bool_prompt("Upload to CPAN?", "y");
    system($self->{exe}, $distfile) and die
        "Upload failed.\n";
}

1;
