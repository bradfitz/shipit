package ShipIt::VC::Mercurial;
use strict;
use base 'ShipIt::VC';
use File::Temp ();

sub command { 'hg' }

sub new {
    my ($class, $conf) = @_;
    my $self = bless {}, $class;
    $self->{push_to} = $conf->value( $self->command . ".push_to" );
    return $self;
}

=head1 NAME

ShipIt::VC::Mercurial -- ShipIt's Mercurial support

=head1 CONFIGURATION

In your .shipit configuration file, the following options are recognized:

=over

=item B<hg.push_to>

If you want the newly created to be pushed elsewhere (for instance in your
public Mercurial repository), then you can specify the destination in this variable

=back

=cut

sub exists_tagged_version {
    my ($self, $ver) = @_;

    my $command = $self->command;
    my $x = `$command tags`;
    return $x =~ m/^$ver\s/m;
}

sub commit {
    my ($self, $msg) = @_;

    my $command = $self->command;

    if ( my $unk = `$command status -u` ) {
        die "Unknown local files:\n$unk\n\nUpdate .hgignore, or $command add them";
        exit(1);
    }

    # commit
    system($command, "commit", "-m", $msg);
}

sub local_diff {
    my ($self, $file) = @_;
    my $command = $self->command;
    return `$command diff $file`;
}

sub tag_version {
    my ($self, $ver, $msg) = @_;
    $msg ||= "Tagging version $ver.\n";

    warn "TAG: $msg, $ver";

    system($self->command, "tag", "-m", $msg, $ver)
        and die "Tagging of version '$ver' failed.\n";

    if (my $where = $self->{push_to}) {
        warn "pushing to $where";
        system($self->command, "push", $where);
    }
}

sub are_local_diffs {
    my ($self) = @_;
    my $command = $self->command;
    my $diff = `$command status`;
    return $diff =~ /\S/ ? 1 : 0;
}

1;
