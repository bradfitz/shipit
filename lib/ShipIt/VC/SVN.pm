package ShipIt::VC::SVN;
use strict;
use base 'ShipIt::VC';
use File::Temp ();

sub command { 'svn' }

sub new {
    my ($class, $conf) = @_;
    my $self = bless {}, $class;
    $self->{tagpattern} = $conf->value( $self->command . ".tagpattern" );

    my $command = $self->command;
    my $url = $self->find_url
        or die "Failed to run $command, or this isn't an $command working copy";
    $self->{url} = $url;

    $self->{dir_exists} = {}; # url -> 1 (url exists, learned from svn ls)
    $self->{dir_listed} = {}; # url -> 1 (have we do svn ls on url?)
    return $self;
}

sub find_url {
    my $self = shift;
    my $info = `svn info`;
    ($info =~ /^URL: (.+)/m)[0];
}

=head1 NAME

ShipIt::VC::SVN -- ShipIt's subversion support

=head1 CONFIGURATION

In your .shipit configuration file, the following options are recognized:

=over

=item B<svn.tagpattern>

A pattern which ultimately expands into the absolute subversion URL for a tagged version.  If the pattern isn't already absolute, the conventional "tags" directory is used as a base.  The pattern has one magic variable, %v, which expands to the version number being tagged.  If no %v is found, it's placed at the end.

Example legit values:

=over 8

=item http://example.com/svn/tags/MyProject-%v

=item MyProject-%v

Both the above are equivalent.

=item (nothing)

Will automatically add %v to the end (of nothing), then auto-find your
'tags' URL, resulting in a final URL of:

 http://example.com/svn/tags/%v

If your svn repo hosts more than one project, this default URL could
be bad, as the tagged directory has no project name in it.

=back

=back

=cut

sub exists_tagged_version {
    my ($self, $ver) = @_;

    my $command = $self->command;
    my $url = $self->_tag_url_of_version($ver);
    die "bogus chars in $command url" if $url =~ /[ \`\&\;]/;

    my $tag_base = $url;
    $tag_base =~ s!/[^/]+$!! or die;
    unless ($self->{dir_listed}{$tag_base}++) {
        foreach my $f (`$command ls $tag_base`) {
            chomp $f;
            $self->{dir_exists}{"$tag_base/$f"} = 1;
        }
    }

    return $self->{dir_exists}{$url} || $self->{dir_exists}{"$url/"};
}

# returns tag url of a given version, with no trailing slash
sub _tag_url_of_version {
    my ($self, $ver) = @_;
    my $url = $self->{tagpattern} || '';
    unless ($url =~ m!^[\w\+]+://!) {
        $url = $self->_tag_base . $url;
    }
    $url .= "%v" unless $url =~ /\%v/i;
    $url =~ s/\%v/$ver/ig;
    $url =~ s!/+$!!;
    return $url;
}

sub _tag_base {
    my ($self) = @_;
    my $url = $self->{url};
    $url =~ s!/trunk.*!/tags/!;
    return $url;
}

sub commit {
    my ($self, $msg) = @_;

    my $command = $self->command;

    # any locally-added files not in svn?
    my $unk;
    my $changed = 0;
    foreach (`$command st`) {
        $changed++;
        next unless /^\?/;
        $unk .= $_;
    }
    if ($unk) {
        die "Unknown local files:\n$unk\n\nUpdate $command:ignore with:\n\t$command pe svn:ignore .\n";
        exit(1);
    }

    unless ($changed) {
        warn "No locally changed files, skipping commit\n";
        return;
    }

    # commit
    my $tmp_fh = File::Temp->new(UNLINK => 1, SUFFIX => '.msg');
    print $tmp_fh $msg;
    my $tmp_fn = "$tmp_fh";
    system($command, "ci", "--file", $tmp_fn) and die "Commit failed.\n";
}

sub local_diff {
    my ($self, $file) = @_;
    my $command = $self->command;
    return `$command diff $file`;
}

sub tag_version {
    my ($self, $ver, $msg) = @_;
    $msg ||= "Tagging version $ver.\n";
    my $tmp_fh = File::Temp->new(UNLINK => 1, SUFFIX => '.msg');
    print $tmp_fh $msg;
    my $tmp_fn = "$tmp_fh";
    my $tag_url = $self->_tag_url_of_version($ver);
    system($self->command, "copy", "--file", $tmp_fn, $self->{url}, $tag_url)
        and die "Tagging of version '$ver' failed.\n";
}

sub are_local_diffs {
    my ($self) = @_;
    my $command = $self->command;
    my $diff = `$command diff`;
    return $diff =~ /\S/ ? 1 : 0;
}

1;


