package ShipIt::VC::SVN;
use strict;
use base 'ShipIt::VC';

sub new {
    my ($class, $conf) = @_;
    my $self = bless {}, $class;
    $self->{tagpattern} = $conf->value("svn.tagpattern");

    my $info = `svn info`;
    unless ($info =~ /^URL: (.+)/m) {
        die "Failed to run svn, or this isn't an svn working copy";
    }
    $self->{url} = $1;
    warn "in url $self->{url}\n";

    return $self;
}

=head1 NAME

ShipIt::VC::SVN -- ShipIT's subversion support 

=head1 CONFIGURATION

In your .shipit configuration file, the following options are recognized:

=over

=item B<svn.tagformat>

A pattern which ultimately expands into the absolute subversion URL for a tagged version.  If the pattern isn't already absolute, the conventional "tags" directory is used as a base.  The pattern has one magic variable, %v, which expands to the version number being tagged.  If no %v is found, it's placed at the end.

Example legit values:

=list

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



sub commit {
    die "ABSTRACT";
}

sub tag_version {
    die "ABSTRACT";
}

sub exists_tagged_version {
    my ($self, $ver) = @_;
    my $url = $self->_tag_url_of_version($ver);
    my $ans = system("svn", "-q", "ls", $url) ? 0 : 1;
    warn "does $url exist? ans=$ans\n";
    return $ans;
}

sub _tag_url_of_version {
    my ($self, $ver) = @_;
    my $url = $self->{tagpattern};
    unless ($url =~ m!^[\w\+]+://!) {
        $url = $self->_tag_base . $url;
    }
    $url .= "%v" unless $url =~ /\%v/i;
    $url =~ s/\%v/$ver/ig;
    return $url;
}

sub _tag_base {
    my ($self) = @_;
    my $url = $self->{url};
    $url =~ s!/trunk.*!/tags/!;
    return $url;
}

1;


