# to process the auto file to prepare the data for plot

#20160720105801
#Total Accesses: 634938
#Total kBytes: 2904387
#CPULoad: .554708
#Uptime: 59680
#ReqPerSec: 10.639
#BytesPerSec: 49834
#BytesPerReq: 4684.07
#BusyWorkers: 1
#IdleWorkers: 19
#Scoreboard: .._._._._.....__..._.___............_.___._....._...._...W................._....................................................._..............................................................................................................................

# 2 r    Requests currenty being processed
# 3 i    Idle workers
# 4 _    Waiting for Connection
# 5 S    Starting up
# 6 R    Reading Request
# 7 W    Sending Reply
# 8 K    Keepalive (read)
# 9 D    DNS Lookup
#10 C    Closing connection
#11 L    Logging
#12 G    Gracefully finishing
#13 I    Idle cleanup of worker
#14 .    Open slot with no current process

my @states = qw(r i _ S R W K D C L G I .);
my %stats;

#Y   m d H M S
#20160720105801
my $date_re = '^(\d{14}?)$';
my $timestamp;

chomp(my @lines = <>);

for my $line (@lines) {
	#print "\"$line\"\n";
	if ($line =~ /$date_re/) {
		$timestamp = $1; # for data structure in memory or just print
		# and postprocess after
		print $timestamp;
	}
	else {
		my @fields = split /: /, $line;
		#print " \"$fields[0]\""; 
		if ($fields[0] eq 'Scoreboard') {
			##print " processing \"$fields[1]\"\n";
			for my $s (@states) {
				$stats{$s} =0;
			}
			my $length = length $fields[1];
			for (my $i = 0; $i < $length; $i++) {
				my $char = substr($fields[1], $i, 1);
				##print "$char($i)=";
				if (exists $stats{$char}) {
					$stats{$char}++;
					#####print "$stats{$char}; ";
				}
				else{
					print STDERR "UNKNOWN state \"$char($i)\" in $fields[1]\n";
				}
			}
			##print "\n";
			for my $s (@states) {
				#print " $stats{$s}:$s";
				print " $stats{$s}";
			}
			print "\n";
		}
		###else {
			###print " $fields[1]";
		###}	
	}
	#print "\n";
}

