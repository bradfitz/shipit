package ShipIt::Util;
use strict;
use Carp qw(croak confess);
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(slurp write_file);

sub slurp {
    my ($file) = @_;
    open (my $fh, $file) or confess "Failed to open $file: $!\n";
    return do { local $/; <$fh>; }
}

sub write_file {
    my ($file, $contents) = @_;
    open (my $fh, ">", $file) or confess "Failed to open $file for write: $!\n";
    print $fh $contents;
    close($fh) or confess "Close failed";
    die "assert" unless -s $file == length($contents);
    return 1;
}
