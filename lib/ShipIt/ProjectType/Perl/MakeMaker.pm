package ShipIt::ProjectType::Perl::MakeMaker;
use strict;
use base 'ShipIt::ProjectType::Perl';
use ExtUtils::Manifest qw(manicheck skipcheck filecheck);
use ShipIt::Util qw(make_var);

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

    # I'm getting sick of making MANIFEST.SKIP files just for the
    # .shipit conf file and dh-make-perl stuff, so let's ignore those
    my %ignore = map { $_ => 1 } qw(
                                    .shipit
                                    install-stamp
                                    build-stamp
                                    );
    @extra = grep { ! $ignore{$_} } @extra;

    my $list = sub {
        join('', map { "$_\n" } @_);
    };

    die "Missing files in MANIFEST, not on disk:\n\n" . $list->(@missing) if @missing;
    die "Extra files on disk, not in MANIFEST:\n\n" . $list->(@extra)     if @extra;

    return 1;
}

sub makedist {
    my $self = shift;
    system("perl", "Makefile.PL") and die "Makefile.PL failed";

    my $file = make_var("DISTVNAME") or die "No DISTVNAME in Makefile";
    $file .= ".tar.gz";
    die "Distfile $file already exists.\n" if -e $file;

    system("make", "dist")        and die "make dist failed";
    die "Distfile $file doesn't exists, but should.\n" unless -e $file;
    return $file;
}

1;

