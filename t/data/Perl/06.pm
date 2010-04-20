package Git::Jira;

use strict;
use warnings;
use Carp;

use version; our $VERSION = qv('1.5');

use base qw(Exporter);
our @EXPORT = qw(branch);

use LWP::UserAgent;
use XML::Simple;
use Term::ANSIColor;

use constant JIRA_LEAD => 'si/jira.issueviews:issue-xml/';

1;
