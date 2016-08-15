use Getopt::Std;
use POSIX;
# brew install st
use lib "/usr/local/Cellar/st/1.1.2/libexec/lib/perl5/site_perl/";
use App::st;

(our $script = $0) =~ s/.*\///;

#0              1 2 3                     4      5     6     7      8         9   10   11    12                   13  14 
#10.110.157.120 - - [08/Jul/2016:11:14:56 +1000] 48543 "POST /b/c/d HTTP/1.1" 200 1279 TLSv1 ECDHE-RSA-AES256-SHA "-" "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)" "0" "-"

my $datePos = 3; 
my $durationPos = 5;
my $duration;
my $codePos = 9; 
my %args;
my $usage = "usage:\t$script [ -d ] [ -h header ] [ -f YYYYMMDDHHMM ] " .
	"[ -t YYYYMMDDHHMM ] \n";

die $usage unless getopts("df:h:t:", \%args);

my $debug = '';
$debug = $args{'d'} if defined $args{'d'};

my $header = 'Responce time';
$header = $args{'h'} if defined $args{'h'};

#           YYYYMMDDHHMMSS
my $from = '00000000000000';
my $to   = '99999999999999';

if(defined $args{'f'}) {
	die "-f \"" . $args{'f'} . "\" must be from 1 to 14 digits\n$usage"
		unless $args{'f'} =~ /^\d{1,14}$/;
		substr($from, 0, length($args{'f'}) ) = $args{'f'};
}

if(defined $args{'t'}) {
	die "-t \"" . $args{'t'} . "\" must be from 1 to 14 digits\n$usage"
		unless $args{'t'} =~ /^\d{1,14}$/;
		substr($to, 0, length($args{'t'}) ) = $args{'t'};
}


print STDERR "$header: from $from to $to\n" if $debug;

my @Mon = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my %Mon;

for (my $i = 0; $i <= $#Mon; $i++) {
	$Mon{$Mon[$i]} = sprintf("%02d", $i + 1);
	#print STDERR "$i $Mon[$i] $Mon{$Mon[$i]}\n" if $debug;
}

my $total = 0;
#                    1      2
#   3          4      5      6
my $datetime_re = '\[(\d\d)/(' . join("|", @Mon) .
')\/(\d\d\d\d):(\d\d):(\d\d):(\d\d)';

my ($convertedDT, %st);

chomp(my @lines = <>);
LINE: for my $line (@lines) {
	my @fields = split / /, $line;
	my $currentDT = $fields[$datePos];

	if($currentDT =~ /$datetime_re/) {
		$convertedDT = "$3" . $Mon{$2} . "$1$4$5$6";
		$code = $fields[$codePos];

		print STDERR "convertedDT=\"$convertedDT\" code=\"$code\"\n" if $debug;

		next unless ($convertedDT >= $from and $convertedDT <= $to and
			$code eq '200');

		my $m1 = substr($fields[$datePos], 13, 5);
		$duration = 0 + $fields[$durationPos];

		if(exists($st{"$m1"})) {
			$st{"$m1"}->process($duration);
		}
		else {
			$st{"$m1"} = App::St->new();
		}
	}
	else {
		warn "Current log record date and time \"$currentDT\" is not in " .
			"\"$datetime_re\" format in {$line}\n";
	}
}

print "$header\nTime\tN\tmin\tmax\tmean\tstddev\tsderr\n";

for my $ten (sort keys %st) {
	print "$ten\t" . $st{"$ten"} -> N();
	print "\t" . $st{"$ten"} -> min();
	print "\t" . $st{"$ten"} -> max();
	print "\t" . $st{"$ten"} -> mean();
	print "\t" . $st{"$ten"} -> stddev();
	print "\t" . $st{"$ten"} -> stderr() . "\n";
}

