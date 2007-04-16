package ShipIt::ProjectType;
use strict;

=head1 NAME

ShipIt::ProjectType - abstract base class for different types of projects

=head1 OVERVIEW

Different types of projects (Perl, C, ...) have different conventions
and quirks which this abstract base class aims to hide.

Currently only Perl is implemented, but an autoconf-y C version is
needed soon for memcached releases, so will come in time.

=head1 SYNOPSIS

 $pt = $state->pt;  # get a ShipIt::ProjectType instance

 $ver = $pt->find_version;
 $pt->update_version("1.53");
 $pt->disttest;

=head1 METHODS

=cut

sub new { bless {}, $_[0] }

=head2 find_version

Returns current version of project.

=cut

sub find_version {
    die "ABSTRACT find_version in $_[0]\n";
}

=head2 update_version($new_ver)

Updates version number on disk with provided new version.

=cut

sub update_version {
    my ($self, $newver) = @_;
    die "ABSTRACT update_version in $_[0]\n";
}

=head2 disttest

Make a dist, then untars that in a temp directory, and does a full
build & test on the extracted archive.  Returns true if everything
succeeds, or dies on failure.

=cut

1;
