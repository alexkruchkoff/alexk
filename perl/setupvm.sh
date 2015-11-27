# $Header$ -- would be nice
our $script;
($script = $0) =~ s/.*\///;

=head1 NAME

B<@@script@@> is a script to create and setup VM in VirtualBox.

=head1 SYNOPSIS

@@script@@ [ -d ] -n name -m ram 

=head1 DESCRIPTION

B<@@script@@> tries to create and setup new F<name> VM in the VirtualBox to
be ready for being kickstarted.

=cut

use strict;
use Getopt::Std;

sub from {
	my ($command) = @_;
	open(README, "$command |") or die "Can not run \"$command\": $!\n";
	chomp(my @lines = <README>);
	close README;
	my $error = $? >> 8;
	#return ($error, join("\n",@lines));
	return ($error, @lines);
}

my %args;
my $usage = "usage: $script [-d] -n name -m ram\n";
die $usage unless getopts("dn:m:", \%args);

our $debug = '';
$debug = $args{'d'} if defined $args{'d'};

my $name = '';
$name = $args{'n'} if defined $args{'n'};

my $ram = '';
$ram = $args{'m'} if defined $args{'m'};

print STDERR "$script name=$name;ram=$ram\n" if $debug;

die $usage unless $name;

my $VBoxManage = '/usr/local/bin/VBoxManage';
my $command = "$VBoxManage list vms 2>&1";

my ($error, @output) = from $command;

die "got an error: $error " . join ("\n", @output) . ".\n" if $error;

my %uuid = ();
my $vm_re = '"([^"]*)" {([^}]*)}';

for my $vm (@output) {
	if ($vm =~ /$vm_re/) {
	 $uuid{$1} = $2;	
	 #print STDERR "$vm: name=\"$1\" uuid=\"$2\";\n" if $debug;
	}
	else { die "can not parse vm: $vm;\n" }
}

if ($debug) {
	print STDERR "vm\tuuid:\n";
	for my $n (sort keys %uuid) {
		print STDERR "$n\t$uuid{$n}\n";
	}
}
