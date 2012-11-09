package ShipIt;
use strict;
use ShipIt::Conf;
use ShipIt::State;
use ShipIt::VC;
use ShipIt::Util;

our $VERSION = '0.58';

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

Three steps:  run "shipit --write-config" to make a dummy/template config, edit config file, then run "shipit" again

=head2 Step 1/3: Write out template config file

In the root directory of your project, run:

  $ shipit --write-config

And it'll bring up your $EDITOR, so you can do step 2...

=head2 Step 2/3: Tweak your config file

The default config file is something like:

  # auto-generated shipit config file.
  steps = FindVersion, ChangeVersion, CheckChangeLog, DistTest, Commit, Tag, MakeDist

  # svn.tagpattern = MyProj-%v
  # svn.tagpattern = http://code.example.com/svn/tags/MyProj-%v

  # CheckChangeLog.files = ChangeLog, MyProj.CHANGES

Tweak away.  You may want to add the "UploadCPAN" step at the end of
steps, as it isn't included by default.  It requires L<cpan-upload> or
L<cpan-upload-http> installed.

The comma-separate steps are L<ShipIt::Step> subclasses.  Each one may
or may accept additional config, as you can see the CheckChangeLog
step does.  (although CheckChangeLog by default figures it out, how
your changelog files are named)

All values have sensible defaults, and any missing/extra keys generate
errors.

For more info on svn.tagpattern, see L<ShipIt::VC::SVN>.

=head2 Step 3/3: Run 'shipit' again

From the root directory of your project, where your new .shipit config file is, type B<shipit>:

   you@host:~/proj$ shipit

And then it does the rest, after verifying with you the version number you want to release.

If you're really cautious, run with "shipit --dry-run" instead.

=head1 CONTRIBUTING

If you'd like to contribute to ShipIt (with either a bug report or patch), see:

L<http://contributing.appspot.com/shipit>

=cut

1;
