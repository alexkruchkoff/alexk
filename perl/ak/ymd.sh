package ak::ymd;
$RCSID = '$Id: ymd.sh,v 1.10 2008/06/25 05:25:56 alexk Exp $';

my @ID = split / /, $RCSID;

=head1 NAME

B<ak::ymd> - a class for dealing with date and time using B<y>ear, B<m>onth, B<d>ay, hour, minute, second...

=cut

# $Id: ymd.sh,v 1.10 2008/06/25 05:25:56 alexk Exp $Header: ]
# line 8 should be a class name

my $VERSION = '0.1';
$VERSION = $ID[2] if scalar(@ID) > 2;

=pod

=head1 VERSION

This document refers to the B<$Revision: 1.10 $> of B<ak::ymd>, released
on B<$Date: 2008/06/25 05:25:56 $>.

=head1 SYNOPSIS

 use ak::ymd;
 my $now = ak::ymd -> new();
 print "Today is " . $now -> Day . "/" . $now -> Month . "/" . $now -> Year
 	. "\n";

 my $arrival = ak::ymd -> new({Year => 2008, Month => 9, Day => 2,
  Hour => 5, Min => 55, });

=head1 DESCRIPTION

B<ak::ymd> is a class for dealing with a moment of time which has following
attributes: an B<y>ear, a B<m>onth, a B<d>ay, an hour, a minute and
a second. Using various methods it is possible to create a new B<ak::ymd>
object or to find out the value of different attributes and more.

=head2 Methods

The following methods are available for B<ak::ymd>.

=cut

use Time::Local;
	# standard in perl 5.8.5
use strict;
use Carp;

=pod

=head3 new 

is used to create a new object of the class B<ak::ymd>.
There are three different ways of creating new object.

=over 4

=item *

Calling the method B<new> without any parameters:

 my $now = ak::ymd -> new();

will create B<ak::ymd> object for the current time.

=item *

Calling the method new with the number of seconds since Epoch:

 my $hour_ago = ak::ymd -> new($now -> seconds - 3600);

will create a new object of the class B<ak::ymd> for the moment of one hour
ago: B<$now -E<gt> seconds> will return the number of seconds since the
Epoch for the object with the name B<$now> and 3600 is the number of
seconds in an hour.

=item *

Calling the method new with the reference to a hash:

 my $arrival = ak::ymd -> new({Year => 2008, Month => 9, Day => 2,
  Hour => 5, Min => 55, });

will create the object B<$arrival> for the moment of 05:55:00 on 02/09/2008.

=back

=cut

# Global 
my $daysInWeek = 7;

sub new {
	my ($class, $param) = @_;
	my ($package, $filename, $line, $subr, $has_args, $wantarray) = caller(0);
	my $debug = '';
	my $seconds;
	if (defined $param) {
		if (ref($param) eq 'HASH') { # default -- current?
			$debug = $param -> {"Debug"} if exists($param -> {"Debug"});
  		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
    		localtime(time);
			$year = exists($param -> {"Year"}) ? $param -> {"Year"} :
				$year + 1900; #current year
			$mon = exists($param -> {"Month"}) ? $param -> {"Month"} - 1: $mon;
			$mday = exists($param -> {"Day"}) ? $param -> {"Day"} : 1;
			$hour = exists($param -> {"Hour"}) ? $param -> {"Hour"} : 0;
			$min = exists($param -> {"Min"}) ? $param -> {"Min"} : 0;
			$sec = exists($param -> {"Sec"}) ? $param -> {"Sec"} : 0;

			warn "Debug $package:$filename:$line: " .
				"$mday/$mon/$year $hour:$min:$sec;\n" if $debug;

			$seconds = timelocal($sec, $min, $hour, $mday, $mon, $year);
		}
		elsif (! ref($param)) {
			$seconds = $param;
		}
		else {	
			croak "$package:$filename:$line: Wrong type of parameter: " .
				ref($param) . " - should be a reference to a hash like " .
				"{Year => 2008, Month => 6, Day => 19, Hour => 15, Min => 30} or " .
				"a number of seconds\n";
		}
	}
	else {
  	$seconds = time;
	}

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
    localtime($seconds);
  my $Year=1900+$year;
  $mday=sprintf("%02d", $mday);
  my $Mon=sprintf("%02d", $mon+1);
  $sec=sprintf("%02d", $sec);
  $min=sprintf("%02d", $min);
  $hour=sprintf("%02d", $hour);

	my $dow = $wday ? $wday : 7; # Mon 1 .. Sun 7

	my $ymd = bless {
  	_Sec => $sec,
		_Min => $min,
		_Hour => $hour,
		_Day => $mday,
		_Month => $Mon,
		_MonthIndex => $mon,
		_Year => $Year,
		_wday => $wday,
		_yday => $yday,
		_isdst => $isdst,
    _seconds => $seconds,
		_DoW => $dow,
		_Debug => $debug,
	}, $class;

  return $ymd;
}

=pod

=head3 Year

Method returns the value of the attribute B<Year> of the object of the class B<ak::ymd>:

 print "The current year is " . $now -> Year . "\n";

=cut

sub Year {
	my ($self) = @_;
	return $self -> { _Year };
}

=pod

=head3 Month

Method returns the B<Month> attribute of the object as 2 characters string
with leading zero like '06' for the June. 

=cut

sub Month {
	my ($self) = @_;
	return $self -> { _Month };
}

=head3 MonthIndex

Method B<MonthIndex> returns the Month index [0..11] for the object of
class B<ak::ymd>.

=cut

sub MonthIndex {
	my ($self) = @_;
	return $self -> { _MonthIndex };
}

=pod

=head3 Day

Method B<Day> returns the Day for the object of class B<ak::ymd>

=cut

sub Day {
	my ($self) = @_;
	return $self -> { _Day };
}

=pod

=head3 Hour

Method B<Hour> returns the Hour for the object of class B<ak::ymd>

=cut

=pod

=head3 Min

Method B<Min> returns the Minute for the object of class B<ak::ymd>

=cut

sub Min {
	my ($self) = @_;
	return $self -> { _Min };
}

=pod

=head3 Sec

Method B<Sec> returns the Second for the object of class B<ak::ymd>

=cut

sub Sec {
	my ($self) = @_;
	return $self -> { _Sec };
}

=pod

=head3 seconds

Method B<seconds> returns the seconds since the Epoch for the object of
class B<ak::ymd>

=cut

sub seconds {
	my ($self) = @_;
	return $self -> { _seconds };
}
=pod

=head3 DoW

Method B<DoW> returns the Day of the Week for the object of
class B<ak::ymd>: from 1 for Monday till 7 for Sunday.

 print "Today is " . $ymd -> DoW . " Day of Week\n";

=cut

sub DoW {
	my ($self) = @_;
	return $self -> { _DoW };
}

=pod

=head3 DoY

Method B<DoY> returns the Day of the Year for the object of
the class B<ak::ymd>.

 print "Today is " . $ymd -> DoW . " Day of Week\n";

=cut

sub DoY {
	my ($self) = @_;
	return $self -> { _yday };
}

=pod

=head3 DebugOn

Method is used for debuginng the module

=cut

sub DebugOn {
	my ($self) = @_;
	$self -> {_Debug} = 1;
	return $self;
}

=pod

=head3 DebugOff

Method is used for debuginng the module

=cut

sub DebugOff {
	my ($self) = @_;
	$self -> {_Debug} = '';
	return $self;
}

=pod

=head3 Debug

Method is used for debuginng the module

=cut

sub Debug {
	my ($self) = @_;
	return $self -> {_Debug};
}

=pod

=head3 DaysPerMonth

Method B<DaysPerMonth> returns the reference to the array which contains
number of days for each month of the year for the object of the class
B<ak::ymd>.

=cut

sub DaysPerMonth {
	my ($self) = @_;
	my ($package, $filename, $line, $subr, $has_args, $wantarray) = caller(0);
	my $debug = $self -> Debug;

	warn "Debugging from $package|$filename|$line called $subr; has_args=" .
		"$has_args; wantarray=$wantarray;\n" if $debug;

	my @mon = qw (January February March April May June July August September
		October November December);
	my %m; for my $m (0..$#mon) { $m{$mon[$m]} = $m; }
	my @days = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

	if($debug) {
		for my $m (0..$#mon) {
			warn "$m $mon[$m] $days[$m{$mon[$m]}]\n";
		}
	}
	my $lastDay = ak::ymd -> new({Year => $self -> Year, Month => 12,
		Day => 31});

	my $lastDayOfYear = $lastDay -> DoY;
	
	warn "$subr lastDay=" . $lastDay -> DoY . " - 364=" .
		($lastDayOfYear - 364) . "; so in " . $m{February} . " month were " .
		$days[$m{February}] . " days and now\n" if $debug;

	$days[$m{February}] += ($lastDayOfYear - 364); #Leap year!

	warn "there are " . $days[$m{February}] . " days\n" if $debug;

	return \@days;
}

=pod

=head3  Sunday

Method B<Sunday> find out the Sunday for the week which given object of the
class B<ak::ymd> belongs to and returns the object of the same class
B<ak::ymd> for the found Sunday.

=cut

sub Sunday {
	my ($self) = @_;
	my ($package, $filename, $line, $subr, $has_args, $wantarray) = caller(0);
	my $debug = $self -> Debug;

	warn "Debugging from $package|$filename|$line called $subr; has_args=" .
		"$has_args; wantarray=$wantarray;\n" if $debug;

	my $sunday;
	my $daysTillSunday = $daysInWeek - $self -> DoW;
	my $daysPerMonthRef = $self -> DaysPerMonth;

	if (($daysTillSunday + ($self -> Day)) >
		($daysPerMonthRef -> [$self -> MonthIndex])) {

		warn "$subr: this month " . $self -> MonthIndex . " has only " .
			($daysPerMonthRef -> [$self -> MonthIndex]) .
			" days.  Sunday will be next month\n" if $debug;

		if(($self -> Month) eq '12') {

			warn "Sunday: next month will be in the next year\n" if $debug;
		
			$sunday = ak::ymd -> new({ #Debug => $debug,
				Year => (1 + $self -> Year),
				Month => 1, Day => ($daysTillSunday + ($self -> Day) -
				($daysPerMonthRef -> [$self -> MonthIndex]))}); 
		}
		else {
			$sunday = ak::ymd -> new({ #Debug => $debug,
				Year => ($self -> Year), Month => (1 + $self -> Month),
				Day => ($daysTillSunday + ($self -> Day)
		 		- ($daysPerMonthRef -> [$self -> MonthIndex]))}); 
		}
	}
	else {
		$sunday = ak::ymd -> new({Year => ($self -> Year),
			Month => ($self -> Month), Day => ($daysTillSunday + $self -> Day)});
	}

	return $sunday;

}

=pod

=head3 WeekDDMM

Method B<WeekDDMM> for a given obect of the class B<ak::ymd> returns the
stack of strings in the form DD/MM for the week of that object.

=cut

sub WeekDDMM {
	my ($self) = @_;
	my ($package, $filename, $line, $subr, $has_args, $wantarray) = caller(0);
	my $debug = $self -> Debug;
	
	warn "Debugging from $package|$filename|$line called $subr; " .
		"has_args=$has_args; wantarray=$wantarray;\n" if $debug;

	my $sunday = $self -> Sunday;
	my $daysPerMonthRef = $self -> DaysPerMonth;
	my @DDMM = ();
	my $sundayDay = 0 + $sunday -> Day;

	if ($sundayDay < $daysInWeek) { # the week begins in the previous month

		my ($previousMonth, $daysInPreviousMonth);
		my $weekDaysFromPreviousMonth = $daysInWeek - $sundayDay;

		warn "the day for sunday is $sundayDay => first " .
			"$weekDaysFromPreviousMonth day(s) from the previous month\n"
			if $debug;

		if($sunday -> MonthIndex == 0) { # December last year + January

			warn "week begins in december\n" if $debug;

			$previousMonth = '12';
			$daysInPreviousMonth = 31;
		}
		else {
			$previousMonth = sprintf("%02d", $sunday -> MonthIndex);
			$daysInPreviousMonth =
				$daysPerMonthRef -> [($sunday -> MonthIndex) - 1];
		}
		for my $day (($daysInPreviousMonth - $weekDaysFromPreviousMonth  + 1)
			.. $daysInPreviousMonth) {
			push @DDMM, sprintf("%02d", $day) . "/" . $previousMonth;
		}
		for my $day (1 .. $sundayDay) {
			push @DDMM, sprintf("%02d", $day) . "/" . $sunday -> Month;
		}
	}
	else { # all week days are from the same month
		for my $day (($sundayDay - $daysInWeek + 1) .. $sundayDay) {
			push @DDMM, sprintf("%02d", $day) . "/" . $sunday -> Month;
		}
	}

	warn join("|",@DDMM) . "\n" if $debug;

	if ($wantarray) { return @DDMM; }
	else {join("|",@DDMM);}
}

1;

