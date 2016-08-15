use POSIX;
# brew install st
use lib "/usr/local/Cellar/st/1.1.2/libexec/lib/perl5/site_perl/";
use App::st;

#0              1 2 3                     4      5     6     7      8         9   10   11    12                   13  14 
#10.110.157.120 - - [08/Jul/2016:11:14:56 +1000] 48543 "POST /b/c/d HTTP/1.1" 200 1279 TLSv1 ECDHE-RSA-AES256-SHA "-" "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)" "0" "-"

my $datePos = 3; 
my $durationPos = 5;
my $duration;
my $codePos = 9; 
my $total = 0;
my (%lpm, %codes, %lpmcode, %total, %st, %min, %max, %avg) = ();
chomp(my @lines = <>);
for my $line (@lines) {
	my @fields = split / /, $line;
	my $m1 = substr($fields[$datePos], 13, 5);
	$duration = 0 + $fields[$durationPos];
	my $code = $fields[$codePos];

	if ($code eq '200') { # success
		#if(exists($min{"$m1"})) {
		if(exists($st{"$m1"})) {
			$st{"$m1"}->process($duration);

			if($duration < $min{"$m1"}) {
				$min{"$m1"} = $duration;
			}

			if($duration > $max{"$m1"}) {
				$max{"$m1"} = $duration;
			}

			$avg{"$m1"} += $duration;
		}
		else {
			$st{"$m1"} = App::St->new();

			$min{"$m1"} = $duration;
			$max{"$m1"} = $duration;
			$avg{"$m1"} = $duration;
		}
	}
	$codes{$fields[$codePos]} = 1;
  $lpm{"$m1"}++;
	$total++;
  $lpmcode{"$m1$fields[$codePos]"}++;
  $total{"$fields[$codePos]"}++;
}

print "time\ttotal";
for my $code (sort keys %codes) {
	print "\t$code";
}
print "\tmin\tmax\tavg\tmin\tmax\tmean\tstddev\n";

for my $ten (sort keys %lpm) {
	print "$ten\t$lpm{$ten}";
	for my $code (sort keys %codes) {
		my $tc = "$ten$code";
		if(exists($lpmcode{$tc})) {
			my $n = $lpmcode{$tc};
			print "\t$n";
		}
		else {
			print "\t0";
		}	
	}
	print "\t" .  floor($avg{"$ten"}/$lpm{"$ten"}) . "\t" .
		$st{"$ten"} -> min() . "\t" .
		$st{"$ten"} -> max() . "\t" .
		floor($st{"$ten"} -> mean()) . "\t" .
		floor($st{"$ten"} -> stddev()) . "\n";
}

print "total\t$total";
for my $code (sort keys %codes) {
	print "\t$total{$code}";
}
print "\n";

print "%\t" , $total/$total*100;
for my $code (sort keys %codes) {
	print "\t", sprintf("%5.2f",$total{$code}/$total*100);
}
print "\n";

