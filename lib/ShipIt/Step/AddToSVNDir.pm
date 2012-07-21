package ShipIt::Step::AddToSVNDir;
use strict;
use base 'ShipIt::Step';
use File::Copy ();
use ShipIt::Util qw(in_dir);
use File::Basename qw(basename);

=head1 NAME

ShipIt::Step::AddToSVNDir - copies/adds/commits distfile to local (svn) directory

=head1 DESCRIPTION

This step takes the resultant distfile and copies it to a local
directory (which is backed by svn), does svn add, svn up, and svn
commits that file.

Presumably, the post-commit hook on that svn repo then triggers some
remote webserver elsewhere to svn up and make the distfile appear to
your users.  (At least that's how it works for me... :))

=head1 CONFIGURATION

In .shipit config:

   AddToSVNDir.dir = /path/to/some/directory/

=cut

sub init {
    my ($self, $conf) = @_;
    $self->{dir} = $conf->value("AddToSVNDir.dir");
    $self->{dir} =~ s/^~/$ENV{HOME}/;
    die "AddToSVNDir.dir not defined in config."     unless $self->{dir};
    die "AddToSVNDir.dir's value isn't a directory." unless -d $self->{dir};
    die "AddToSVNDir.dir's value isn't an svn directory." unless -d "$self->{dir}/.svn";
}

sub run {
    my ($self, $state) = @_;
    my $distfile =  $state->distfile;
    die "No distfile was created!"             unless $distfile;
    die "distfile $distfile no longer exists!" unless -e $distfile;

    if ($state->dry_run) {
        warn "*** DRY RUN, not adding to SVN dir!\n";
        return;
    }

    my $base = basename($distfile);
    die "dest file already exists" if -e "$self->{dir}/$base";

    File::Copy::copy($distfile, $self->{dir}) or
        die "file copy of $distfile to $self->{dir} failed: $!\n";

    in_dir($self->{dir}, sub {
        system("svn", "add", $base) and die "svn add failed";
        system("svn", "up") and die "svn up failed";
        system("svn", "ci", "-m", "auto-adding file using shipit", $base) and die "svn ci failed";
    });

}

1;
