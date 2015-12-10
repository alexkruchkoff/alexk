my $line = join('',<>);
$line =~ s/\n/\\n/gs;
print "$line";
