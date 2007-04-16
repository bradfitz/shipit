package ShipIt::ProjectType::Perl::MakeMaker;
use strict;
use base 'ShipIt::ProjectType::Perl';

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
    return 1;
}

1;

