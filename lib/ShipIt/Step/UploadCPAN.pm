package ShipIt::Step::UploadCPAN;
use strict;
use base 'ShipIt::Step';
use ShipIt::Util qw(bool_prompt);

sub init {
    my ($self, $conf) = @_;
    my $exe;
    $exe = `which cpan-upload-http` || `which cpan-upload`;
    chomp $exe;
    die "cpan-upload-http not found\n" unless $exe;
    $self->{exe} = $exe;
}

sub run {
    my ($self, $state) = @_;
    my $distfile =  $state->distfile;
    die "No distfile was created!"             unless $distfile;
    die "distfile $distfile no longer exists!" unless -e $distfile;

    return unless bool_prompt("Upload to CPAN?", "y");
    system($self->{exe}, $distfile) and die
        "Upload failed.\n";
}

1;
