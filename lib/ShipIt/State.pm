package ShipIt::State;
use strict;
use ShipIt::ProjectType::Perl;
use ShipIt::VC;

=head1 NAME

ShipIt::State - holds state between steps

=head1 OVERVIEW

An instance of type ShipIt::State is passed to each L<ShipIt::Step>'s
'run' method.

=head1 INSTANCE METHODS

=cut

sub new {
    my ($class, $conf) = @_;
    my $self = bless {}, $class;
    $self->{vc} = ShipIt::VC->new($conf);
    $self->{changelogs} = [];
    return $self;
}

=head2 set_version

   $state->set_version("1.34");

Set the version of this release.  (is done by
L<ShipIt::Step::FindVersion>, early in the process, but perhaps you
want to write your own version-detecting/selecting step)

=cut

sub set_version {
    my ($self, $ver) = @_;
    $self->{version} = $ver;
}

=head2 version

   $ver = $state->version

Returns version of release, or dies if not yet set.

=cut

sub version {
    my ($self, $ver) = @_;
    return $self->{version} or die "No version yet set";
}

=head2 pt

    $pt = $state->pt;

Detects/instantiates this project's type (Perl vs autoconf, etc) and
returns a newly-created or previously-cached L<ShipIt::ProjectType>
instance.

=cut

sub pt {
    my $self = shift;
    return $self->{pt} ||= ShipIt::ProjectType->new;
}

=head2 vc

    $vc = $state->vc;

Detects/instantiates the version control system in use (svn, svk, etc)
and returns a newly-created or previously-cached L<ShipIt::VC>
instance.

=cut

# returns a version-control-type instance (created on first access)
sub vc {
    my $self = shift;
    return $self->{vc};
}

=head2 add_changelog_file

    $state->add_changelog_file("CHANGES");

Push a changelog file into the known list.

=cut

sub add_changelog_file {
    my ($self, $file) = @_;
    push @{$self->{changelogs}}, $file;
}

=head2 add_changelog_file

    @files = $state->changelog_files;

Returns list of known changelog files.

=cut

sub changelog_files {
    my $self = shift;
    return @{$self->{changelogs}};
}

=head2 dry_run

   $dry = $state->dry_run;

Accessor for "dry run" flag.  If set, you shouldn't actually
commit/tag/upload stuff... just test if everything would've succeeded.

=cut

sub set_dry_run { $_[0]{dryrun} = $_[1] }
sub dry_run     { $_[0]{dryrun}         }

=head2 set_distfile

=head2 distfile

   $state->set_distfile("foo.tar.gz");
   $file = $state->distfile;

Setter/getter for where the final distfile is.  Useful so steps
that need to build the whole tree (say, in an early "make test"
phase), can keep it around, and later steps (like "make dist") can
access it, without recompiling everything again.

=cut

sub set_distfile { $_[0]{distfile} = $_[1] }
sub distfile     { $_[0]{distfile}         }

1;
