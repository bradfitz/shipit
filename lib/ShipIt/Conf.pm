package ShipIt::Conf;
use strict;

sub parse {
    my ($class, $file) = @_;
    open (my $fh, $file) or die "Error opening config file $file: $!\n";
    my $self = bless {
        val   => {},  # explicitly configured values
        asked => {},  # keys asked for by step plugins
    }, $class;
    my $line = 0;
    while (<$fh>) {
        $line++;
        s/\#.*//;
        next unless /\S/;
        unless (/^\s*(\S+)\s*=\s*(.+?)\s*$/) {
            die "Bogus syntax on line $line:\n  $_";
        }
        $self->{val}{$1} = $2;
    }

    return $self;
}

sub value {
    my ($self, $key) = @_;
    $self->{asked}{$key} = 1;
    return $self->{val}{$key};
}

sub die_if_unknown_keys {
    my $self = shift;
    my @unknown = grep { ! $self->{asked}{$_} } keys %{ $self->{val} } or
        return 1;
    die "Unknown keys in configuration file: " . join(", ", @unknown) . "\n";
}

# returns ShipIt::Step::Foo instances
sub steps {
    my $self = shift;
    my $steps = $self->value("steps") || "FindVersion";
    $self->die_if_unknown_keys;

    return ();
}

1;
