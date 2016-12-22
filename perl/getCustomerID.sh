my $re='<tns:CustomerID>([^<]*)</tns:CustomerID>';
chomp(my @lines = <>);
for my $line (@lines) {
	$line =~ s/$re/print("$1\n")/ge;
}

