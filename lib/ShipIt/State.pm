package ShipIt::State;
use strict;
use ShipIt::ProjectType::Perl;
use ShipIt::VC;

sub new {
    my ($class, $conf) = @_;
    my $self = bless {}, $class;
    $self->{vc} = ShipIt::VC->new($conf);
    $self->{changelogs} = [];
    return $self;
}

sub set_version {
    my ($self, $ver) = @_;
    $self->{version} = $ver;
}

sub version {
    my ($self, $ver) = @_;
    return $self->{version} or die "No version yet set";
}

# returns project-type instance (created on first access)
sub pt {
    my $self = shift;
    return $self->{pt} ||= ShipIt::ProjectType->new;
}

# returns a version-control-type instance (created on first access)
sub vc {
    my $self = shift;
    return $self->{vc};
}

sub add_changelog_file {
    my ($self, $file) = @_;
    push @{$self->{changelogs}}, $file;
}

sub changelog_files {
    my $self = shift;
    return @{$self->{changelogs}};
}

sub set_dry_run { $_[0]{dryrun} = $_[1] }
sub dry_run     { $_[0]{dryrun}         }

1;
