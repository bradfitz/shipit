package ShipIt::ProjectType::Perl::MakeMaker;
use strict;
use base 'ShipIt::ProjectType::Perl';
use ExtUtils::Manifest qw(manicheck skipcheck filecheck);

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new;
    return $self;
}

# returns 1 if a make disttest succeeds.
sub disttest {
    my $self = shift;
    system("perl", "Makefile.PL") and die "Makefile.PL failed";
    system("make", "disttest")    and die "Disttest failed";
    system("make", "distclean")   and die "Distclean failed";

    my @missing    = manicheck;
    my @extra      = filecheck;

    my $list = sub {
        join('', map { "$_\n" } @_);
    };

    die "Missing files in MANIFEST, not on disk:\n\n" . $list->(@missing) if @missing;
    die "Extra files on disk, not in MANIFEST:\n\n" . $list->(@extra)     if @extra;

    return 1;
}

1;

