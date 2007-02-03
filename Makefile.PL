#!/usr/bin/perl
#
#   Perl Makefile for Perlbal
#   $Id: Makefile.PL 554 2006-09-03 09:18:05Z hachi $
#
#   Invoke with 'perl Makefile.PL'
#
#   See ExtUtils::MakeMaker (3) for more information on how to influence
#    the contents of the Makefile that is written
#

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                    => 'ShipIt',
    VERSION_FROM            => 'lib/ShipIt.pm',
    AUTHOR                  => 'Brad Fitzpatrick <brad@danga.com>',
    ABSTRACT_FROM           => 'lib/ShipIt.pm',

    PREREQ_PM               => {
    },
              );


