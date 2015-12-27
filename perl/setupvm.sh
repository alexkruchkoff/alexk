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

if (exists $uuid{$name}) {
	print STDERR "vm \"$name\" already exists with uuid: \"$uuid{$name}\"\n"
		if $debug;
	$command = "$VBoxManage showvminfo \"$uuid{$name}\" 2>&1";
	($error, @output) = from $command;
	die "got an error: $error " . join ("\n", @output) . ".\n" if $error;
	for my $line (@output) {
		print STDERR "\"$line\"\n" if $debug;
	}
} # check if exists uuid
else { # new VM
	$command = "$VBoxManage createvm --name \"$name\" --register 2>&1";
	($error, @output) = from $command;
	print STDERR "command: \"$command\"\n" if $debug;
	die "got an error: $error " . join ("\n", @output) . ".\n" if $error;
	for my $line (@output) {
		print STDERR "\"$line\"\n" if $debug;
		# get uuid
	}
	# --boot1 disk
	# --boot2 net
	# --boot<1-4> none|floppy|dvd|disk|net
	# VBoxManage modifyvm \"$name\" --boot1 disk --boot2 net --boot3 none --boot4 none --ioapic on --nic1 nat --nictype1 82540EM --nattftpfile1 /pxelinux.0 --natsettings1 16000,128,128,0,0 --natdnshostresolver1 on --uart1 0x3F8 4 --uartmode1 file /tmp/\"$name\".serial --rtcuseutc on --ostype RedHat_64  --usb on --usbehci on
	# VBoxManage modifyvm ento --natpf1 "guestssh,tcp,,6666,,22" # which port 6666 ?
	# VBoxManage storagectl \"$name\" --name IDE --add ide --controller PIIX4 --portcount 2 --bootable on
	# VBoxManage storagectl \"$name\" --name SATA --add sata --controller IntelAhci  --portcount 1 --bootable on
	# VBoxManage storageattach \"$name\" --storagectl IDE --port 1 --device 0 --medium emptydrive
	#
	# VBoxManage createmedium disk --filename "/Users/alexk/VirtualBox VMs/ento/ento.vdi" --size 204800 --format VDI --variant Standard; echo $?
	#0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
	Medium created. UUID: b10000a6-4500-4160-8672-56082cd9ecfc
	#0
	#
  # VBoxManage storageattach ento --storagectl SATA --port 0 --device 0 --type hdd --medium b10000a6-4500-4160-8672-56082cd9ecfc
}

