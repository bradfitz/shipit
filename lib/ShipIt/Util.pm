package ShipIt::Util;
use strict;
use Carp qw(croak confess);
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(slurp write_file bool_prompt edit_file $term);
use Term::ReadLine ();

our $term = Term::ReadLine->new("prompt");

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

sub bool_prompt {
    my ($q, $def) = @_;
    $def = uc($def || "");
    die "bogus default" unless $def =~ /^[YN]?$/;
    my $opts = "[y/n]";
    $opts = "[Y/n]" if $def eq "Y";
    $opts = "[y/N]" if $def eq "N";
    my $to_bool = sub {
        my $yn = shift;
        return 1 if $yn =~ /^y/i;
        return 0 if $yn =~ /^n/i;
        return undef;
    };
    while (1) {
        my $ans = $term->readline("$q $opts");
        my $bool = $to_bool->($ans || $def);
        return $bool if defined $bool;
        warn "Please answer 'y' or 'n'\n";
    }
}

sub edit_file {
    my ($file) = @_;
    my $editor = $ENV{"EDITOR"} || "vi";
    system($editor, $file);
}

1;
