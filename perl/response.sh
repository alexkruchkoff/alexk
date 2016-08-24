use warnings;
use Getopt::Std;
use POSIX;

(our $script = $0) =~ s/.*\///;

sub microsecs {
	my $mcs = $_[0];
	my $ms = 1000;
	my $sec = 1000000;
	my $min = 60000000;
	# μs ms s min

	#print STDERR "INPUT \"$mcs\" μs\n";

	my $str = '';

	if ($mcs > $min) {
		my $m = floor($mcs/$min);
		$str .= "$m&nbsp;min&nbsp;";
		$mcs -= $m * $min;

		#print STDERR "$m min \"$mcs\" μs\n";
	}

	if ($mcs > $sec) {
		my $s = floor($mcs/$sec);
		$str .= "$s&nbsp;s&nbsp;";
		$mcs -= $s * $sec;

		#print STDERR "$s sec \"$mcs\" μs\n";
	}

	if ($mcs > $ms) {
		my $mil = floor($mcs/$ms);
		$str .= "$mil&nbsp;ms&nbsp;";
		$mcs -= $mil * $ms ;

		#print STDERR "$mil ms " . ($mil * $ms) . " \"$mcs\" μs\n";
	}

	$mcs = floor($mcs); # don't need fractions of microsecond

	$str .= "$mcs&nbsp;μs";
	#print STDERR "\"$mcs\" μs\n******************************************\n";

	return $str;
}

#0              1 2 3                     4      5     6     7             8         9   10   11    12                   13  14 
#10.110.157.120 - - [08/Jul/2016:11:14:56 +1000] 48543 "POST /abra/cadabra HTTP/1.1" 200 1279 TLSv1 ECDHE-RSA-AES256-SHA "-" "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)" "0" "-"

my $datePos = 3; 
my $durationPos = 5;
my $methodPos = 6;
my $pathPos = 7;
my $codePos = 9; 

my %args;
my $usage = "usage:\t$script [ -d ] [ -h header ] [ -f YYYYMMDDHHMM ] " .
	"[ -t YYYYMMDDHHMM ] [ -c errorCode ] \n";

die $usage unless getopts("df:h:t:c:", \%args);

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


my $errorCode = '200';
$errorCode = $args{'c'} if defined $args{'c'};

print STDERR "$header: from $from to $to for code $errorCode\n" if $debug;

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

my ($convertedDT, $code, $method, $path, $duration, %calls, %minResponse,
	%maxResponse, %avgResponse, %minDT, %maxDT, $timeStamp, $bg);

my $n = 0;

print STDERR "datetime_re=\"$datetime_re\"\n" if $debug;

print "<h3>$header</h3>\n<table border cellspacing=0 cellpadding=5>" .
	"<tr bgcolor=\"#c0c0c0\"><th>Resource</th><th>Total Calls</th>" .
	"<th>Min Response</th><th>Max Response</th><th>Avg Response</th></tr>\n";

chomp(my @lines = <>);
LINE: for my $line (@lines) {
	print STDERR "{$line}\n" if $debug;
	my @fields = split / /, $line;
	my $currentDT = $fields[$datePos];
	print STDERR "currentDT=\"$currentDT\"\n" if $debug;

	if($currentDT =~ /$datetime_re/) {
		$convertedDT = "$3" . $Mon{$2} . "$1$4$5$6";
		$code = $fields[$codePos];

		print STDERR "convertedDT=\"$convertedDT\" code=\"$code\"\n" if $debug;

		next unless ($convertedDT >= $from and $convertedDT <= $to and
			$code eq $errorCode);

		$method = substr($fields[$methodPos],1);
		$path = $fields[$pathPos];
		$duration = 0 + $fields[$durationPos];

		$timeStamp = substr($currentDT, 1);
		my $resource = "$method $path";
		print STDERR "PROCESSING: resource=\"$resource\" " .
			"duration=\"$duration\"\n" if $debug;

		if(exists($calls{$resource})) {
			$calls{$resource}++;

			if($duration < $minResponse{$resource}) {
				$minResponse{$resource} = $duration;
				$minDT{$resource} = $timeStamp;
			}

			if($duration > $maxResponse{$resource}) {
				$maxResponse{$resource} = $duration;
				$maxDT{$resource} = $timeStamp;
			}

			$avgResponse{$resource} += $duration;

		}
		else {
			$calls{$resource} = 1;
			$minResponse{$resource} = $duration;
			$maxResponse{$resource} = $duration;
			$avgResponse{$resource} = $duration;
			$minDT{$resource} = $timeStamp;
			$maxDT{$resource} = $timeStamp;
		}
	}
	else {
		warn "Current log record date and time \"$currentDT\" is not in " .
			"\"$datetime_re\" format in {$line}\n";
	}
}

for my $r (sort keys %calls) {
	$bg = "bgcolor=\"#" . (($n++ % 2) ? "aaddff" : "ddeeff") . "\"";

	$total += $calls{$r};
	print "<tr $bg><td>$r</td><td>$calls{$r}</td><td>" .
		microsecs($minResponse{$r}) . "<br/>$minDT{$r}</td><td>" .
		microsecs($maxResponse{$r}) . "<br>$maxDT{$r}</td><td>" .
		microsecs($avgResponse{$r}/$calls{$r}) . "</td></tr>\n";
}

print "</table>\n";

print "<b> Total Calls: $total</b>\n";

