package ShipIt::State;
use strict;
use ShipIt::ProjectType::Perl;

sub new {
    my ($class) = @_;
    return bless {}, $class;
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

1;
