use Getopt::Std;

(our $script = $0) =~ s/.*\///;

sub indent {
	my $string = $_[0];
	$string =~ s/^[^\S\n]+//gm;
	return $string;
}

# 1 t    time YmdHMS
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

my %states = ("r" => "Requests currenty being processed",
"i" => "Idle workers", "_" => "Waiting for Connection",
"S" => "Starting up", "R" => "Reading Request", "W" => "Sending Reply",
"K" => "Keepalive (read)", "D" => "DNS Lookup", "C" => "Closing connection",
"L" => "Logging", "G" => "Gracefully finishing",
"I" => "Idle cleanup of worker",
"." => "Open slot with no current process");

my @states = qw(r i _ S R W K D C L G I .);
my %colors = ("r" => 1, "i" => 2, "_" => 3, "S" => 4, "R" => 5, "W" => 6, "K" => 137, "D" => 8, "C" =>13, "L" => 10, "G" => 11, "I" => 12, "." => 7);
my %args;
my $usage = "usage:\t$script [ -d ] -t title -s r|i|_|S|R|W|K|D|C|L|G|I|.  -f file  ...\n";

die $usage unless getopts("df:s:t:", \%args);

my $debug = '';
$debug = $args{'d'} if defined $args{'d'};

die $usage unless defined  $args{'f'};
die $usage unless defined  $args{'s'};
die $usage unless defined  $args{'t'};

my $file = $args{'f'};
my $state = $args{'s'};
my $title = $args{'t'};

die $usage unless exists  $states{$state};

my %n;
for (my $i = 0; $i <= $#states; $i++) {
	print STDERR "$i ", $i + 2, " $states[$i]\n" if $debug;
	$n{$states[ $i ]} = $i + 2;
}

my $ylabel = "$state $states{$state}";
my $column = $n{$state};
my $color = $colors{$state};

my $gnuplot = '/usr/local/bin/gnuplot';

my $gnupl = indent <<"EOSPLOT";
	set terminal png
	set nokey
	set grid
	set title "$title"
	set xdata time
	set timefmt "%H%M%S"
	set format x "%H:%M"
	set ylabel "$ylabel"
	plot "$file" using 1:$column with boxes lt $color
EOSPLOT

print STDERR "draw=$gnupl;" if $debug;

open(GNUPLOT,"| $gnuplot");
print GNUPLOT $gnupl;
close GNUPLOT;

