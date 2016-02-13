=head1 NAME

B<getmp3i> - get info from mp3 files

=head1 SYNOPSIS

B<getmp3i> [ -d ] [ -u ] file...

=head1 DESCRIPTION

B<getmp3i> prints information about mp3 files specified on command line

=head2 Options

=over 4

=item -d

Print debugging info on STDERR

=item -u

For utf8 encoded data

=back

=cut

use strict;
use Getopt::Std;
use MP3::Info;
use Encode;

(our $script = $0) =~ s/.*\///;

my %args;
my $usage = "usage:\t$script [ -d ] [ -u ] file...\n";

die $usage unless getopts("du", \%args);

my $debug = '';
$debug = $args{'d'} if defined $args{'d'};

my $use_utf8 = '';
$use_utf8 = $args{'u'} if defined $args{'u'};

my @files = @ARGV if scalar(@ARGV);

print scalar(@files) . " files have been given\n" if $debug;

for my $file (@files) {
	my $mp3 = get_mp3info($file) or die "error: no tag info for $file: $!\n";
	for my $key (sort keys %$mp3) {
		print "  $key=";
		if ($use_utf8) {
			print	encode("utf8", $mp3 -> {$key}), ";\n";
		}
		else {
			print	$mp3 -> {$key}, ";\n";
		}
	}
	$mp3 = get_mp3tag($file) or die "error: no tag info for $file: $!\n";
	print "File $file:\n" if $debug;
	for my $key (sort keys %$mp3) {
		print "  $key=";
		if ($use_utf8) {
			print	encode("utf8", $mp3 -> {$key}), ";\n";
		}
		else {
			print	$mp3 -> {$key}, ";\n";
		}
	}
}

