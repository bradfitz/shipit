package ShipIt::Conf;
use strict;

=head1 NAME

ShipIt::Conf -- holds/parses config info for a project

=head1 SYNOPSIS

 # done for you:
 my $conf = ShipIt::Conf->parse(CONFFILE);

 # fetch keys out of it in your Step's init method
 package ShipIt::Step::Custom;
 use base 'ShipIt::Step';
 sub init {
     my ($self, $conf) = @_;
     ....
     $self->{foo} = $conf->value("foo_key");
     ....
 }

=cut

=head1 CLASS METHODS

=head2 parse

  $conf = ShipIt::Conf->parse(".shipit");

Returns a ShipIt::Conf object from a file.  Dies on parse failure.

=cut

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

=head2 write_template

    ShipIt::Conf->write_template($file);

Writes out a dummy config file to the provided $file.

=cut

sub write_template {
    my ($class, $file) = @_;
    my $steps = $class->default_steps;

    open (my $fh, ">$file") or die "Error opening for write config file $file: $!\n";
    my $c = "# auto-generated shipit config file.
steps = $steps

# svn.tagpattern = MyProj-%v
# svn.tagpattern = http://code.example.com/svn/tags/MyProj-%v

# CheckChangeLog.files = ChangeLog, MyProj.CHANGES
";
    print $fh $c;
    close($fh) or die;
}

=head1 INSTANCE METHODS

=head2 value

  $val = $conf->value($key);

Fetch a config value.  (also marks it as a known key, so any unknown
keys in a .shipit config file cause a configuration error)

=cut

sub value {
    my ($self, $key) = @_;
    $self->{asked}{$key} = 1;
    return $self->{val}{$key};
}

=head2 die_if_unknown_keys

Die if any key exists which has never been asked for.

=cut

sub die_if_unknown_keys {
    my $self = shift;
    my @unknown = grep { ! $self->{asked}{$_} } keys %{ $self->{val} } or
        return 1;
    die "Unknown keys in configuration file: " . join(", ", @unknown) . "\n";
}

sub default_steps {
    return join(", ",
                qw(
                   FindVersion
                   ChangeVersion
                   CheckChangeLog
                   DistTest
                   Commit
                   Tag
                   MakeDist
                   ));
}

=head2 steps

Returns array of ShipIt::Step instances, based on the value of
B<steps> in your .shipit config file.  For instance, in your .shipit file:

  steps = FindVersion, ChangeVersion, Commit, Tag, MakeDist

The makes ShipIt::Step::FindVersion loaded & instantiated (with 'new', which
calls by default 'init'), followed by ChangeVersion, etc.

=cut

# returns ShipIt::Step::Foo instances
sub steps {
    my $self = shift;
    my $steps = $self->value("steps") || $self->default_steps;

    my @ret;
    foreach my $sname (split(/\s*,\s*/, $steps)) {
        die "Bogus step name: $sname\n" unless $sname =~ /^[\w+:]+$/;
        my $class = "ShipIt::Step::$sname";
        my $rv = eval "use $class; 1;";
        die "Failed to load step module $class: $@\n" unless $rv;
        push @ret, $class->new($self);
    }

    $self->die_if_unknown_keys;
    return @ret;
}

1;
