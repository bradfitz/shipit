package ShipIt::Step::UploadCPAN;
use strict;
use base 'ShipIt::Step';
use ShipIt::Util qw(bool_prompt);

sub init {
    my ($self, $conf) = @_;
    my $exe;
    $exe = `which cpan-upload-http` || `which cpan-upload`;
    die "cpan-upload-http not found\n" unless $exe;
    chomp $exe;
    $self->{exe} = $exe;
}

sub run {
    my ($self, $state) = @_;
    return unless bool_prompt("Upload to CPAN?", "y");
    system($self->{exe}, $state->distfile) and die
        "Upload failed.\n";
}

1;
