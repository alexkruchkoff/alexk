sub sp2_ {
	my ($txt) = @_;
	##print STDERR "txt=$txt;\n";
	$txt =~ s/\s+/_/g;
	##print STDERR "modified txt=$txt;\n";
	return "\"$txt\"";
}

my $re = '"([^"]*)"';
chomp(my @lines = <>);
for my $line (@lines) {
	##print STDERR "line=$line;\n";
	$line =~ s/$re/sp2_($1)/ge;
	##print STDERR "modified line=$line;\n";
	print "$line\n";
}

