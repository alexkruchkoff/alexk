use warnings;
use Getopt::Std;

sub fromFile {
	my ($file) = @_;
	open(FILE, "<", "$file") or die "Can not read \"$file\": $!\n";
	chomp(my @lines = <FILE>);
	close FILE;
	return unless defined wantarray;
	return wantarray ? @lines : join("\n",@lines);
}

sub toFile {
	my ($file, $txt) = @_;
	open(FILE, ">", "$file") or die "Can not write to \"$file\": $!\n";
  prit FILE $txt;
	close FILE;
}

($script = $0) =~ s/.*\///;
my $usage = "usage $script [-d] <file> <re> <from>\n";
my %args;
die $usage unless getopts("d", \%args);
die $usage if scalar(@ARGV) != 3;

my $debug = '';
$debug = $args{'d'} if defined $args{'d'};

my ($file, $re, $from) = @ARGV;

print STDERR "$script file=\"$file\" re=\'$re\' from=\"$from\"\n" if $debug;

my $original = fromFile $file;
print STDERR "original text: \"$original\".\n" if $debug;

my $txt = fromFile $from;

print STDERR "replacing with text: \"$txt\".\n" if $debug;

#if ($original =~ s|($re)|$txt\n|ms) {
if ($original =~ s|($re)|$txt|ms) {
	print STDERR "replacing \"$1\" with new text\n" if $debug;
}
else {
	die "sorry can not find text in original file matching \'$re\'\n";
}

print STDERR "deleting other text matching \'$re\'\n" if $debug;

while ($original =~ s|($re)||ms) {
	print STDERR "removing \"$1\"\n" if $debug;
}

print STDERR "new text \"$original\".\n" if $debug;

toFile $file, $original;

print STDERR "done.\n" if $debug;

