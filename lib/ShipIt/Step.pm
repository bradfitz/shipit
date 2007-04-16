package ShipIt::Step;
use strict;

=head1 NAME

ShipIt::Step - a unit of work to be done prior to a release

=head1 OVERVIEW

Each step is implemented as a ShipIt::Step subclass, implementing an 'init' and 'run' method.

=cut

sub new {
    my ($class, $conf) = @_;
    my $self = bless {}, $class;
    $self->init($conf);
    return $self;
}

=head1 METHODS

=head2 init($conf)

Given the provided L<ShipIt::Conf> object, retrieve configuration keys
your step know about (using $conf->value($key)), and set fields in
$self (an empty hashref) for use later, in the 'run' method.  You
can't access the configuration later in the 'run' method, as the
configuration is then locked down, already having been sanity checked
for unknown or missing keys.

=cut

# should override, if step needs configuration
sub init {
    my ($self, $conf) = @_;
}

=head2 run($state)

Run your step.  Return on success, die on failure.

Use the provided L<ShipIt::State> $state object to inquire about the
state of the release thus far, as populated by previous steps.

=cut

# return if okay, die if problems.
sub run {
    my ($self, $state) = @_;
    warn "Running NO-OP base class 'run' for step $self\n";
}

=head1 SEE ALSO

L<ShipIt> - the ShipIt system itself

L<ShipIt::State>

L<ShipIt::Conf>

L<ShipIt::Step::FindVersion>

L<ShipIt::Step::ChangeVersion>

L<ShipIt::Step::DistTest>

L<ShipIt::Step::Commit>

L<ShipIt::Step::Tag>

L<ShipIt::Step::Release>

=cut

1;
