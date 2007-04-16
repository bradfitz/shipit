package ShipIt::VC;
use strict;
use ShipIt::VC::SVN;

=head1 NAME

ShipIt::VC -- abstract base class for version control systems

=head1 SYNOPSIS

 # done for you, elsewhere
 ... ShipIt::VC->new($conf)

 # get your instance from your state handle:
 $vc = $state->vc;

 # then
 $vc->commit($msg);
 $vc->tag_version("1.25"[, $msg]);
 $vc->exists_tagged_version("1.25"); # 1
 $vc->local_diff("ChangeLog");       # returns diff of changelog

=head1 OVERVIEW

ShipIt::VC is an abstract base class, with a factory method 'new' to
return a subclass instance for the version control system detected to
be in use.

Rather than using 'new' directly, you should call your
L<ShipIt::State> $state's "vc" accessor method, which returns a
memoized (er, singleton) instance of ShipIt::VC->new.

=cut

sub new {
    my ($class, $conf) = @_;
    return ShipIt::VC::SVN->new($conf) if -e ".svn";
    die "Unknown/undetected version control system.  Currently only svn is supported.";
}

=head1 ABSTRACT METHODS

=head2 commit($msg);

Commit all outstanding changes in working copy to repo, with provided commit message.

=cut

sub commit {
    my ($self, $msg) = @_;
    die "ABSTRACT commit method for $self";
}

=head2 tag_version($ver[, $msg]);

Tag the current version (already committed) as the provided version number.

=cut

sub tag_version {
    my ($self, $ver, $msg) = @_;
    die "ABSTRACT commit tag_version for $self";
}

=head2 exists_tagged_version($ver)

Returns true if the given version is already tagged.

=cut

sub exists_tagged_version {
    my ($self, $ver) = @_;
    die "ABSTRACT exists_tagged_version for $self";
}

=head2 local_diff($file)

Returns diff of $file from what's on the server compared to the local on-disk copy.

=cut

sub local_diff {
    my ($self, $file) = @_;
    die "ABSTRACT local_diff for $self";
}

1;
