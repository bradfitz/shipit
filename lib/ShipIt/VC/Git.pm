package ShipIt::VC::Git;
use strict;
use base 'ShipIt::VC';
use File::Temp ();

sub command { 'git' }

sub new {
    my ($class, $conf) = @_;
    my $self = bless {}, $class;
    $self->{tagpattern} = $conf->value( $self->command . ".tagpattern" );
    $self->{sign_tag} = $conf->value( $self->command . ".sign_tag" );
    $self->{push_to} = $conf->value( $self->command . ".push_to" );
    return $self;
}

=head1 NAME

ShipIt::VC::Git -- ShipIt's git support

=head1 CONFIGURATION

In your .shipit configuration file, the following options are recognized:

=over

=item B<git.tagpattern>

Defines how the tag are defined in your git repo.

=item B<git.sign_tag>

This should be set to a truthy value, if you wish the tags to be GPG signed.
(C<git tag -s ...>)

=item B<git.push_to>

If you want the newly created to be pushed elsewhere (for instance in your
public git repository), then you can specify the destination in this variable

=back

=cut

sub exists_tagged_version {
    my ($self, $ver) = @_;

    my $command = $self->command;
    my $x = `git tag -l $ver`;
    chomp $x;
    return $x;
}

sub commit {
    my ($self, $msg) = @_;

    my $command = $self->command;

    if ( my $unk = `git ls-files -z --others --exclude-per-directory=.gitignore --exclude-from=.git/info/exclude` ) {
        $unk =~ s/\0/\n/;
        die "Unknown local files:\n$unk\n\nUpdate .gitignore, or $command add them";
        exit(1);
    }

    # commit
    my $tmp_fh = File::Temp->new(UNLINK => 1, SUFFIX => '.msg');
    print $tmp_fh $msg;
    my $tmp_fn = "$tmp_fh";
    system($command, "commit", "-a", "-F", $tmp_fn);

    if (my $where = $self->{push_to}) {
        my $branch = $self->_get_branch;
        if ($branch) {
            warn "pushing to $where";
            system($self->command, "push", $where, $branch);
        }
    }
}

sub _get_branch {
    my $self = shift;

    open my $fh, '<', '.git/HEAD';
    chomp(my $head = do { local $/; <$fh> });
    close $fh;

    my ($branch) = $head =~ m!ref: refs/heads/(\S+)!;
    return $branch;
}

sub local_diff {
    my ($self, $file) = @_;
    my $command = $self->command;
    return `$command diff --no-color HEAD $file`;
}

sub _tag_of_version {
    my ($self, $ver) = @_;
    my $tag = $self->{tagpattern} || '';
    $tag .= "%v" unless $tag =~ /\%v/i;
    $tag =~ s/\%v/$ver/ig;
    return $tag;
}

sub tag_version {
    my ($self, $ver, $msg) = @_;
    $msg ||= "Tagging version $ver.\n";
    my $tmp_fh = File::Temp->new(UNLINK => 1, SUFFIX => '.msg');
    print $tmp_fh $msg;
    my $tmp_fn = "$tmp_fh";
    my $tag = $self->_tag_of_version($ver); 
    system($self->command, "tag", "-a", ($self->{sign_tag} ? "-s" : ()), "-F", $tmp_fn, $tag)
        and die "Tagging of version '$ver' failed.\n";

    if (my $where = $self->{push_to}) {
        warn "pushing to $where";
        system($self->command, "push", $where, tag => $tag);
    }
}

sub are_local_diffs {
    my ($self, $ver) = @_;
    my $command = $self->command;
    my $diff = `$command diff --no-color $ver`;
    return $diff =~ /\S/ ? 1 : 0;
}

1;
