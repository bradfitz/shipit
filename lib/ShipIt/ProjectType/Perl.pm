package ShipIt::ProjectType::Perl;
use strict;
use base 'ShipIt::ProjectType';
use File::Spec;
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

    if (-e "Build.PL") {
        return $self->{version} = $self->current_version_from_buildpl;
    } else {
        return $self->{version} = $self->current_version_from_makefilepl;
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
        if (/(?:(?:all|version)_from|reference_module)(?:\s*\(|\s+)([\'\"])(.+?)\1/) {
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

sub current_version_from_buildpl {
    my $self = shift;
    open (my $fh, "Build.PL") or die "Can't open Build.PL: $!\n";
    while (<$fh>) {
        if (/\bdist_version_from\b.+([\'\"])(.+?)\1/) {
            $self->{ver_from} = $2;
            last;
        }
        if (/\bmodule_name\b.+([\'\"])(.+?)\1/) {
            $self->{ver_from} = $self->_module_to_file($2);
            # no last since we prefer dist_version_from
        }
        if (/\bdist_version\b.+([\'\"])(.+?)\1/) {
            return $2;
        }
    }
    close($fh);
    return $self->version_from_file;
}

sub _module_to_file {
    my ($self, $mod) = @_;

    my @parts = split /::/, $mod;
    $parts[-1] .= q{.pm};

    unshift @parts, 'lib' if -d 'lib';

    return File::Spec->catfile(@parts);
}

sub _versioncode_from_string {
    my ($self, $string) = @_;

    if ($string =~ /
                    (
                        ( use \s* version \s* ; \s* )?
                        (our)? \s* \$VER SION \s* = \s*              # trick PAUSE from parsing this line
                        (
                                           ['"] v?[\d\.\_]+ ['"]
                            |      q{1,2}\( \s* v?[\d\.\_]+ \s* \)
                            |                   [\d\.\_]+
                            |  qv\( \s* ['"] v? [\d\.\_]+ ['"] \s* \)
                        )
                    )
                /xms) {
        return $1;
    }

    return 0;
}

# returns $VERSION from a file, assuming $self->{ver_from} is already set
sub version_from_file {
    my $self = shift;
    my $file = $self->{ver_from} or die "no ver_from set";
    open (my $fh, $file) or die "Failed to open $file: $!\n";
    while (my $line = <$fh>) {
        if (my $versionpart = $self->_versioncode_from_string($line)) {
            eval {
                package __ShipIt_Temp_Package;
                use vars qw($VERSION);
                eval $versionpart;
            };
            next if $@;
            return $__ShipIt_Temp_Package::VERSION;
        }
    }
    die "No \$VERSION found in file $file\nMaybe, you forgot to quote \$VERSION?";
}

sub update_version {
    my ($self, $newver) = @_;

    if (my $file = $self->{ver_from}) {
        my $contents = slurp($file);

        my $versionpart = $self->_versioncode_from_string($contents);
        my $newversionpart = $versionpart;
        my $version_withoutv = $self->{version};
        $version_withoutv =~ s/^v//;
        $newversionpart =~ s/ v? $version_withoutv /$newver/xms;

        my ($x, $y) = (quotemeta($versionpart), $newversionpart);
        $contents =~ s/$x/$y/;
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
