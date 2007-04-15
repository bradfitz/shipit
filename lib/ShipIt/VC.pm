package ShipIt::VC;
use strict;
use ShipIt::VC::SVN;

=head1 NAME

ShipIt::VC -- abstract base class for version control systems

=head1 SYNOPSIS

 $vc = ShipIt::VC->new($conf);
 $vc->commit($msg);
 $vc->tag_version("1.25"[, $msg]);
 $vc->exists_tagged_version("1.25");  # 1

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

sub commit {
    die "ABSTRACT";
}

sub tag_version {
    die "ABSTRACT";
}

sub exists_tagged_version {
    die "ABSTRACT";
}

1;






