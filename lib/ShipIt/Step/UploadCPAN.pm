package ShipIt::Step::UploadCPAN;
use strict;
use base 'ShipIt::Step';
use ShipIt::Util qw(bool_prompt);
use File::Spec;

sub init {
    my ($self, $conf) = @_;
    my $exe = '';
    PATH: foreach my $dir (File::Spec->path) {
        for my $command (qw(cpan-upload-http cpan-upload)) {
            if (-x File::Spec->catfile($dir, $command)) {
                $exe = $command;
                last PATH;
            }
        }
    }
    die "cpan-upload-http not found\n" unless $exe;
    $self->{exe} = $exe;
    $self->{user} = $conf->value("UploadCPAN.user");
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

    my @options;
    push @options, "-u", $self->{user}, "-p", "" # reset password in case you have ~/.pause
        if $self->{user};
    system($self->{exe}, @options, $distfile) and die
        "Upload failed.\n";
}

1;
