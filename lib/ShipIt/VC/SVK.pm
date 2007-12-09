package ShipIt::VC::SVK;
use strict;
use base 'ShipIt::VC::SVN';
use File::Temp ();

sub command { 'svk' }

sub find_url {
    my $self = shift;
    my $info = `svk info`;
    ($info =~ /^Depot Path: (.+)/m)[0];
}

sub _tag_url_of_version {
    my ($self, $ver) = @_;
    my $url = $self->{tagpattern} || '';
    unless ($url =~ m!^/!) {
        $url = $self->_tag_base . $url;
    }
    $url .= "%v" unless $url =~ /\%v/i;
    $url =~ s/\%v/$ver/ig;
    $url =~ s!/+$!!;
    return $url;
}

=head1 NAME

ShipIt::VC::SVK -- ShipIt's SVK support

=head1 CONFIGURATION

In your .shipit configuration file, the following options are recognized:

=over

=item B<svk.tagpattern>

A pattern which ultimately expands into the absolute subversion URL for a tagged version.  If the pattern isn't already absolute, the conventional "tags" directory is used as a base.  The pattern has one magic variable, %v, which expands to the version number being tagged.  If no %v is found, it's placed at the end.

Example legit values:

=over 8

=item //example/tags/MyProject-%v

=item MyProject-%v

Both the above are equivalent.

=item (nothing)

Will automatically add %v to the end (of nothing), then auto-find your
'tags' URL, resulting in a final URL of:

 //example/tags/%v

If your svk depot hosts more than one project, this default URL could
be bad, as the tagged directory has no project name in it.

=back

=back

=cut

1;


