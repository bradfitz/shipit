package ShipIt::ProjectType::Perl::MakeMaker;
use strict;
use base 'ShipIt::ProjectType::Perl';
use ExtUtils::Manifest qw(manicheck skipcheck filecheck);
use ShipIt::Util qw(make_var);
use Config;

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new;
    my $make = $Config{make} or die "You don't have make";
    my $quot = $^O eq 'MSWin32' ? q/"/ : q/'/;
    $make = "$quot$make$quot" if $make =~ /\s/ && $make !~ /^$quot/;
    $self->{make} = $make;
    return $self;
}

sub prepare_build {
    my $self  = shift;
    system("perl", "Makefile.PL") and die "Makefile.PL failed";
}

sub run_build {
    my $self = shift;
    my($cmd) = @_;

    !system($self->{make}, $cmd);
}

# returns 1 if a make disttest succeeds.
sub disttest {
    my $self = shift;

    $self->prepare_build;
    $self->run_build('disttest')  or die "Disttest failed";
    $self->run_build('distclean') or die "Distclean failed";

    my @missing    = manicheck;
    my @extra      = filecheck;

    # Module::Install creates inc/ in perl Makefile.PL and META.yml in make
    my $missing_ignore = join "|", qw{ ^(MY)?META\.(yml|json)$ ^inc/ };
    @missing = grep { $_ !~ $missing_ignore } @missing;

    # I'm getting sick of making MANIFEST.SKIP files just for the
    # .shipit conf file and dh-make-perl stuff, so let's ignore those
    my %ignore = map { $_ => 1 } qw(
                                    .shipit
                                    install-stamp
                                    build-stamp
                                    );
    @extra = grep { ! ($ignore{$_} || /^\.git/) } @extra;

    my $list = sub {
        join('', map { "$_\n" } @_);
    };

    die "Missing files in MANIFEST, not on disk:\n\n" . $list->(@missing) if @missing;
    die "Extra files on disk, not in MANIFEST:\n\n" . $list->(@extra)     if @extra;

    return 1;
}

sub makedist {
    my $self = shift;
    $self->prepare_build;

    my $file = make_var("DISTVNAME") or die "No DISTVNAME in Makefile";
    $file .= ".tar.gz";
    die "Distfile $file already exists.\n" if -e $file;

    $self->run_build("dist") or die "make dist failed";
    die "Distfile $file doesn't exists, but should.\n" unless -e $file;
    return $file;
}

1;

