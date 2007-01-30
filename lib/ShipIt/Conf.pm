package ShipIt::Conf;
use strict;

sub parse {
    my ($class, $file) = @_;
    open (my $fh, $file) or die "Error opening config file $file: $!\n";
    return bless {}, $class;
}

# returns ShipIt::State::Foo instances
sub steps {
    return ();
}

1;
