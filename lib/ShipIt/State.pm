package ShipIt::State;
use strict;
use ShipIt::ProjectType::Perl;
use ShipIt::VC;

sub new {
    my ($class, $conf) = @_;
    my $self = bless {}, $class;
    $self->{vc} = ShipIt::VC->new($conf);
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
    return $self->{pt} if $self->{pt};

    if (-e "Makefile.PL") {
        return $self->{pt} = ShipIt::ProjectType::Perl->new;
    }

    die "Unknown project type!  Can't find Makefile.PL or (future:) autoconf, etc..";
}

# returns a version-control-type instance (created on first access)
sub vc {
    my $self = shift;
    return $self->{vc};
}

1;
