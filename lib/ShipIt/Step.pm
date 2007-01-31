package ShipIt::Step;
use strict;

sub new {
    my ($class, $conf) = @_;
    my $self = bless {}, $class;
    $self->init($conf);
    return $self;
}

sub init {
    my ($self, $conf) = @_;
    warn "Running NO-OP base class 'init' for step $self\n";
}

# return if okay, die if problems.
sub run {
    my ($self, $state) = @_;
    warn "Running NO-OP base class 'run' for step $self\n";
}

1;
