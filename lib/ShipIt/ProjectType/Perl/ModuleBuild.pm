package ShipIt::ProjectType::Perl::ModuleBuild;
use strict;
use base 'ShipIt::ProjectType::Perl::MakeMaker';

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new;
    return $self;
}

sub prepare_build {
    my $self  = shift;
    system("perl", "Build.PL") and die "Build.PL failed";
}

sub run_build {
    my $self = shift;
    my($cmd) = @_;

    !system("perl", "Build", $cmd);
}

1;

