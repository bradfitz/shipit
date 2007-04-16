package ShipIt;
use strict;
use vars qw($VERSION);
use ShipIt::Conf;
use ShipIt::State;
use ShipIt::VC;
use ShipIt::Util;

$VERSION = '0.40';

=head1 NAME

ShipIt - software release tool

=head1 SYNOPSIS

 shipit

=head1 OVERVIEW

Releasing a new version of software takes a lot of steps... finding the next version number (and making sure you didn't already use that version number before), making sure your changelog is updated, making sure your "make dist" results in a tarball that builds, commiting changes (with updated version number), tagging, and uploading the tarball somewhere.

Or maybe more steps.  Or not some of the above.  Maybe you forgot something!  And maybe you manage multiple projects, and each project has a different release process.

This is all a pain in the ass.

You want to be hacking, not jumping through hoops.

Your contributors want to see their patches actually make it into a release, which won't happen if you're afraid of releases.

B<shipit> automates all the hell.  It makes life beautiful.

=head1 HOW TO USE

Two steps:  make a config file (which may be empty), and then type "shipit".

=head2 Step 1/2: Make a config file

In the root directory of your project, make a file named B<.shipit>.  The structure of the file is:

   # a comment
   key = value
   key2 = value2

   # blank lines don't matter

All values have sensible defaults, and any missing/extra keys generate errors.  For more information on things you
can configure, see L<ShipIt::Conf>.

=head2 Step 2/2: Run 'shipit'

From the root directory of your project, where the shipit config file is, type B<shipit>:

   you@host:~/proj$ shipit

And then it does the rest, after verifying with you the version number you want to release.

=cut

1;
