package ShipIt::ProjectType::Perl;
use strict;
use base 'ShipIt::ProjectType';
use ShipIt::Util qw(slurp write_file);
use ShipIt::ProjectType::Perl::MakeMaker;
use ShipIt::ProjectType::Perl::ModuleBuild;

# factory when called directly.
# returns undef if not a perl project, otherwise returns
# ::MakeMaker or ::ModuleBuild instance.
sub new {
    my ($class) = @_;
    if ($class eq "ShipIt::ProjectType::Perl") {
        return ShipIt::ProjectType::Perl::ModuleBuild->new if -e "Build.PL";
        return ShipIt::ProjectType::Perl::MakeMaker->new   if -e "Makefile.PL";
        return undef;
    }
    return bless {}, $class;
}

# fields:
#   version -- if defined, cached current version
#   ver_from -- if Makefile.PL says so, what file our $VERSION comes from

sub current_version {
    my $self = shift;
    return $self->{version} if defined $self->{version};

    if (-e "Makefile.PL") {
        return $self->{version} = $self->current_version_from_makefilepl;
    } else {
        die "TODO: don't yet support Module::Build, etc...\n";
    }
}

sub current_version_from_makefilepl {
    my $self = shift;
    open (my $fh, "Makefile.PL") or die "Can't open Makefile.PL: $!\n";
    while (<$fh>) {
        # MakeMaker
        if (/VERSION_FROM.+([\'\"])(.+?)\1/) {
            $self->{ver_from} = $2;
            last;
        }
        # Module::Install
        if (/(?:all|version)_from(?:\s*\(|\s+)([\'\"])(.+?)\1/) {
            $self->{ver_from} = $2;
            last;
        }
        if (/\bVERSION\b.+([\'\"])(.+?)\1/) {
            return $2;
        }
    }
    close($fh);
    return $self->version_from_file;
}

# returns $VERSION from a file, assuming $self->{ver_from} is already set
sub version_from_file {
    my $self = shift;
    my $file = $self->{ver_from} or die "no ver_from set";
    open (my $fh, $file) or die "Failed to open $file: $!\n";
    while (<$fh>) {
        return $2 if /\$VERSION\s*=\s*([\'\"])(.+?)\1/;
    }
    die "No \$VERSION found in file $file\n";
}

sub update_version {
    my ($self, $newver) = @_;

    if (my $file = $self->{ver_from}) {
        my $contents = slurp($file);
        $contents =~ s/(\$VERSION\s*=\s*([\'\"]))(.+?)\2/$1$newver$2/
            or die "Failed to replace version.  Where is \$VERSION line?\n";

        write_file($file, $contents);
        return 1;
    }

    if (-e "Makefile.PL") {
        my $file = "Makefile.PL";
        my $contents = slurp($file);
        $contents =~ s/(\bVERSION\b.+)([\'\"])(.+?)\2/$1$2$newver$2/
            or die "Failed to replace VERSION in MakeFile.PL\n";
        write_file($file, $contents);
        return 1;

    }

    die "perl update not done";
}

1;
