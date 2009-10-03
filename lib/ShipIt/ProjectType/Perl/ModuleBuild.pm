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

sub makedist {
    my $self = shift;
    $self->prepare_build;

    require Module::Build;
    my $build = Module::Build->current;

    my $file = $build->dist_dir;
    $file .= ".tar.gz";
    die "Distfile $file already exists.\n" if -e $file;

    $self->run_build("dist") or die "make dist failed";
    die "Distfile $file doesn't exists, but should.\n" unless -e $file;
    return $file;
}

1;

