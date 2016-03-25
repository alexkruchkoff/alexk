my $txt = <>;
$txt =~ s/\m/\n/gms;
print $txt;
