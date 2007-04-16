package ShipIt::ProjectType::AutoConf;
use strict;
use base 'ShipIt::ProjectType';
use ShipIt::Util qw(slurp write_file tempdir_obj);
use File::Copy ();
use Cwd;

# factory when called directly.
# returns undef if not a perl project, otherwise returns
# ::MakeMaker or ::ModuleBuild instance.
sub new {
    my ($class) = @_;
    return undef unless -e "configure.ac";
    my $self = $class->SUPER::new;
    return $self;
}

sub current_version {
    my ($self) = @_;
    my $conf = slurp("configure.ac");
    die "No AC_INIT found" unless
        $conf =~ /^AC_INIT\((.+?), (\S+?), .+\)/m;
    $self->{projname}  = $1;
    $self->{projver}   = $2;
    return $2;
}

sub update_version {
    my ($self, $newver) = @_;
    my $conf = slurp("configure.ac");
    $conf =~ s/^AC_INIT\((.+?), (\S+?), (.+)\)/AC_INIT($1, $newver, $3)/m
        or die "update_version regpexp failed";
    write_file("configure.ac", $conf);
}

sub makedist {
    my $self = shift;
    my $distfile = $self->_build_tempdist;
    return $distfile;
}

sub disttest {
    my ($self) = @_;
    my $distfile = $self->_build_tempdist;

    # debug,
    my $size = -s $distfile;
    warn "distfile = $distfile (size = $size)\n";

    my ($basename) = $distfile =~ m!([^/]+)$! or die;

    my $testdir_o = tempdir_obj();
    my $testdir   = $testdir_o->directory;
    File::Copy::copy($distfile, $testdir)
        or die "Copy from $distfile to $testdir failed: $!\n";

    my $old_cwd = getcwd;
    warn "Changing to tempdir $testdir for make/make test...\n";
    chdir($testdir) or die "chdir to testdir $testdir failed";
    system("tar -zxvf $basename") and die "untar failed";

    my ($untardir) = $basename =~ m!^(.+)\.tar\.gz$! or die;
    die "Expected untarred dir $untardir, but not there" unless -d $untardir;
    chdir($untardir) or die;

    system("./configure")  and die "configure during test failed";
    system("make")         and die "make during test failed";
    system("make", "test") and die "make test failed";

    # restore old working directory
    chdir($old_cwd) or die;

    return 1;
}

sub _build_tempdist {
    my $self = shift;

    my $projname = $self->{projname} or die "no projname found?";
    my $projver  = $self->{projver}  or die "no projver found?";
    my $distfile = "$projname-$projver.tar.gz";

    # did we already build it for a DistTest step earlier?
    if (my $tdir = $self->{dist_tempdirobj}) {
        my $file = $tdir->directory . "/$distfile";
        return $file if -e $file;
    }

    die "Distfile $distfile already exists" if -e $distfile;

    if (-e "Makefile") {
        system("make", "distclean")   and die "Distclean failed";
    }

    if (-x "autogen.sh") {
        system("./autogen.sh") and die "autogen.sh failed";
    }

    system("./configure")  and die "configure failed";
    system("make", "dist") and die "make dist failed";

    die "Distfile $distfile doesn't exist" unless -e $distfile;

    # throw object in $self, so it doesn't get rmtree'd until
    # $self goes out of scope, later.
    my $tdir = $self->{dist_tempdirobj} = tempdir_obj();

    File::Copy::move($distfile, $tdir->directory) or 
        die "Failed to move dist $distfile to tempdir";

    return $tdir->directory . "/$distfile";
}

1;
