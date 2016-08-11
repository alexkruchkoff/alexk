#0              1 2 3                     4      5     6     7      8         9   10   11    12                   13  14 
#10.110.157.120 - - [08/Jul/2016:11:14:56 +1000] 48543 "POST /b/c/d HTTP/1.1" 200 1279 TLSv1 ECDHE-RSA-AES256-SHA "-" "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)" "0" "-"

my $datePos = 3; 
my $codePos = 9; 
my $total = 0;
my (%lpm, %codes, %lpmcode, %total) = ();
chomp(my @lines = <>);
for my $line (@lines) {
	my @fields = split / /, $line;
	my $m10 = substr($fields[$datePos], 13, 4) . "0";
	$codes{$fields[$codePos]} = 1;
  $lpm{"$m10"}++;
	$total++;
  $lpmcode{"$m10$fields[$codePos]"}++;
  $total{"$fields[$codePos]"}++;
}

print "time\ttotal";
for my $code (sort keys %codes) {
	print "\t$code";
}
print "\n";

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
	print "\n";
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

