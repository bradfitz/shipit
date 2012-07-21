package ShipIt::Util;
use strict;
use Carp qw(croak confess);
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(slurp write_file bool_prompt edit_file $term make_var tempdir_obj
                    find_subclasses in_dir);
use Term::ReadLine ();
use File::Temp ();
use File::Path ();
use Cwd;

our $term;

# We may not get a terminal if we're running under an automatic build tool.
eval {
    Term::ReadLine->new("prompt");
};

sub slurp {
    my ($file) = @_;
    open (my $fh, $file) or confess "Failed to open $file: $!\n";
    return do { local $/; binmode $fh; <$fh>; }
}

sub write_file {
    my ($file, $contents) = @_;
    open (my $fh, ">", $file) or confess "Failed to open $file for write: $!\n";
    binmode $fh;
    print $fh $contents;
    close($fh) or confess "Close failed";
    die "assert" unless -s $file == length($contents);
    return 1;
}

sub bool_prompt {
    my ($q, $def) = @_;
    $def = uc($def || "");
    die "bogus default" unless $def =~ /^[YN]?$/;
    return $def if !$term;
    my $opts = " [y/n]";
    $opts = " [Y/n]" if $def eq "Y";
    $opts = " [y/N]" if $def eq "N";
    my $to_bool = sub {
        my $yn = shift;
        return 1 if $yn =~ /^y/i;
        return 0 if $yn =~ /^n/i;
        return undef;
    };
    while (1) {
        my $ans = $term->readline("$q$opts ");
        my $bool = $to_bool->($ans || $def);
        return $bool if defined $bool;
        warn "Please answer 'y' or 'n'\n";
    }
}

sub edit_file {
    my ($file) = @_;
    my $editor = $ENV{"EDITOR"} || "vi";
    system($editor, $file);
}

sub make_var {
    my $var = shift;
    my $file = slurp("Makefile");
    return undef unless $file =~ /^\Q$var\E\s*=\s*(.+)\s*/m;
    return $1;
}

sub find_subclasses {
    # search for any other custom project type modules
    my $class = shift;
    my @classes = ();  
    for my $dir (@INC) {
        for my $file (glob("$dir/" . join("/", split(/::/, $class)) . "/*.pm")) {
            if($file =~ /\/(\w+)\.pm/) {
                push(@classes, "$class" . "::" . "$1");
            }
        }
    }
    return @classes;
}

# returns either $obj or ($obj->dir, $obj), when in list context.
# when $obj goes out of scope, all temp directory contents are wiped.
sub tempdir_obj {
    my $dir = File::Temp::tempdir() or
        die "Failed to create temp directory: $!\n";
    my $obj = bless {
        dir => $dir,
    }, "ShipIt::Util::TempDir";
    return wantarray ? ($dir, $obj) : $obj;
}

# run a coderef in another directory, then return to old directory,
# even if $code dies.
sub in_dir {
    my ($dir, $code) = @_;
    my $old_cwd = getcwd;
    chdir($dir) or die "chdir to dir $dir failed: $!\n";
    my $rv = eval { $code->(); };
    my $err = $@;
    chdir($old_cwd) or die "chdir back to $old_cwd failed: $!\n";
    die $err if $err;
    return $rv;
}


############################################################################

package ShipIt::Util::TempDir;
sub directory { $_[0]{dir} };
sub DESTROY {
    my $self = shift;
    File::Path::rmtree($self->{dir}) if $self->{dir} && -d $self->{dir};
}


1;
