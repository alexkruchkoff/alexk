sub id {
	my ($id) = @_;
	print "$id\n";
	return $id;
}
my $re='<tns:CustomerID>([^<]*)</tns:CustomerID>';
chomp(my @lines = <>);
for my $line (@lines) {
	$line =~ s/$re/id($1)/ge;
}

