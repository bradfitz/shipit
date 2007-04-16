package ShipIt::ProjectType;
use strict;
use ShipIt::ProjectType::Perl;
use ShipIt::ProjectType::AutoConf;

=head1 NAME

ShipIt::ProjectType - abstract base class for different types of projects

=head1 OVERVIEW

Different types of projects (Perl, C, ...) have different conventions
and quirks which this abstract base class aims to hide.

=head1 SYNOPSIS

 $pt = $state->pt;  # get a ShipIt::ProjectType instance

 $ver = $pt->find_version;
 $pt->update_version("1.53");
 $pt->disttest;

=head1 METHODS

=cut

sub new {
    my ($class) = @_;
    my $pt;

    # when called as a factory, return the appropriate subtype
    if ($class eq "ShipIt::ProjectType") {
        # returns undef if not a perl project,
        $pt = ShipIt::ProjectType::Perl->new;
        return $pt if $pt;

        $pt = ShipIt::ProjectType::AutoConf->new;
        return $pt if $pt;

        die "Unknown project type.  Can't find Makefile.PL, Build.PL, configure.ac, etc..";
    }

    # if we're being called via ->SUPER::new from child class,
    # give them their blessed object
    return bless {}, $class;
}

=head2 find_version

Returns current version of project.

=cut

sub find_version {
    die "ABSTRACT find_version in $_[0]\n";
}

=head2 update_version($new_ver)

Updates version number on disk with provided new version.

=cut

sub update_version {
    my ($self, $newver) = @_;
    die "ABSTRACT update_version in $self\n";
}

=head2 disttest

Make a dist, then untars that in a temp directory, and does a full
build & test on the extracted archive.  Returns true if everything
succeeds, or dies on failure.

=cut

sub disttest {
    my ($self) = @_;
    die "ABSTRACT distest in $self\n";
}

=head2 makedist

Runs "make dist" or equivalent, to build the resultant archive to give
to users.  Dies on failure, or returns the path (relative or absolute)
to the dist file.

=cut

sub makedist {
    my ($self) = @_;
    die "ABSTRACT makedist in $self\n";
}


1;
