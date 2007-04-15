package ShipIt::Step::CheckChangeLog;
use strict;
use base 'ShipIt::Step';
use ShipIt::Util qw(bool_prompt edit_file);

sub init {
    my ($self, $conf) = @_;

    # by default, we search for these files.  if they explicitly provide
    # one or more, we fail hard if one doesn't exist
    $self->{explicit} = 0;
    $self->{files}    = [ "Changes", "ChangeLog", "CHANGES" ];

    # get them both (don't short-circuit), to mark them as known config
    # keys in the Conf class.
    my $file  = $conf->value("CheckChangeLog.file");
    my $files = $conf->value("CheckChangeLog.files");

    if (my $cs_list = ($file || $files)) {
        $self->{explicit} = 1;
        $self->{files}    = [ split /\s*,\s*/, $cs_list ];
    }
}

sub run {
    my ($self, $state) = @_;

    my $seen = 0;
    foreach my $file (@{ $self->{files} }) {
        unless (-e $file) {
            # die if they explicitly listed a changelog file,
            die "Missing explicit ChangeLog file: $file\n" if $self->{explicit};
            # else just proceed, hoping we find one of the defaults...
            next;
        }
        $seen++;

        # already have a ChangeLog entry?
        next if $self->check_file_for_version($file, $state->version);

        # else, ask if they want to edit the file to correct it.
        if (bool_prompt("Edit file?", "y")) {
            edit_file($file);
        } else {
            die "Aborting.\n";
        }

        $self->check_file_for_version($file, $state->version)
            or die "Aborting.\n";
    }
    die "No changelog file.  Either make one named one of {@{$self->{files}}}, or explicitly list 1+ in a comma-separated list using the configuration key 'CheckChangeLog.files'\n" unless $seen;
}

sub check_file_for_version {
    my ($self, $file, $version) = @_;

    # FUTURE:
    #   my $clf = ShipIt::ChangeLogFile->new($file);
    #   $clf is ShipIt::ChangeLogFile::FormatType (some subclass)
    #   $cltype->has_version($version)
    #   $cltype->add_version($version)  # adds bullet with "NEW STUFF HERE"
    #   system($EDITOR, $file) to tweak it
    #   die unless $cltype->has_version($version) && ! $cltype->has_template_bullet_still;

    # For now, assume a version number on one of the first ten unindented lines

    open(my $fh, $file) or die "Failed to open $file: $!\n";
    while (<$fh>) {
        # no blanket lines
        next unless /\S/;
        # skip things that look like bullets
        next if /^\s+/;
        next if /^\*/;
        next if /^\-/;
        # seen it?
        return 1 if /\Q$version\E/;
    }
    warn "No mention of version '$version' in changelog file '$file'\n";
    return 0;
}

1;
