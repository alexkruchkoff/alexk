# $Header$ -- would be nice

($script = $0) =~ s/.*\///;

=head1 NAME

B<@@script@@> is a script to create and setup VM in VirtualBox.

=head1 SYNOPSIS

@@script@@ [ -d ] -n name -m ram 

=head1 DESCRIPTION

B<@@script@@> tries to create and setup new F<name> VM in the VirtualBox to
be ready for being kickstarted.

=cut

use Getopt::Std;

my %args;
my $usage = "usage: $script [-d] -n name -m ram\n";
die $usage unless getopts("dn:m:", \%args);

our $debug = '';
$debug = $args{'d'} if defined $args{'d'};

my $name = '';
$name = $args{'n'} if defined $args{'m'};

my $ram = '';
$file2 = $args{'m'} if defined $args{'m'};

print STDERR "$script name=$name;ram=$ram\n" if $debug;

die $usage unless $name;

