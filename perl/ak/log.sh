package ak::log;
$RCSID='$Id: log.sh,v 1.13 2007/01/06 05:01:53 alexk Exp $';
my @ID = split / /, $RCSID;
$VERSION = $ID[2];

=head1 NAME

B<ak::log> - logfile tools

=head1 VERSION

This document refers to the $Revision: 1.13 $ of ak::log, released
on $Date: 2007/01/06 05:01:53 $.

=head1 SYNOPSIS

Utilities for logging the debugging messages.

	use ak::log;
	$log = ak::log -> new (
    path        => '/tmp/my.log',
    debug_level =>6,
	  permissions => 0664,
	  divider     => "*********************************"
  );
	$log -> put(4, "var=$var;\n");
	$log -> set_debug_level(2);
	$log -> put(4, "this text will not be logged\n");
	$log -> close();

=head1 DESCRIPTION

The module B<ak::log> is a set of utilities for logging the debugging
information.
To create a new object of the class B<ak::log> load the module:

	use ak::log;

and use the constructor open:

	my $log = ak::log -> new(%param);

where I<path> is the path to the log file.
If it is not defined the log file will be the standard output.

=cut

use ak::lock;
use strict;
use File::Copy;
use FileHandle;
use Carp;

sub new {
	my ($class, %params) = @_;
	my $fh = FileHandle -> new ;
	my $path = exists($params{"path"}) ? $params{"path"} : undef;
	my $debug_level = exists($params{"debug_level"}) ?
		$params{"debug_level"} : 4;
	my $permissions = exists($params{"permissions"}) ?
		$params{"permissions"} : 0664 ;
	my $lock_perm = exists($params{"lock_perm"}) ? $params{"lock_perm"} :
		0664;
	my $divider = exists($params{"divider"}) ?  $params{"divider"} :
		"*\t" x 10 . "\n";
	
	my $log = bless {
		_path => $path,
		_debug_level => $debug_level,
		_permissions => $permissions,
		_lock_perm => $lock_perm,
		_divider => $divider,
		_fh => $fh,
		_opened => '',
	}, $class;

	$log -> open if $log -> { _debug_level };
	return $log;
}

sub info {
	my ($self) = @_;
	my %info = ();
	for my $k (keys %$self) {
		$info{$k} = $self -> {$k};
	}
	return %info;
}

sub open {
	my ($self) = @_;

	$self -> close if $self -> { _opened };

	my ($package, $filename, $line, $subr, $has_args, $wantarray) =
		caller(0);

	my $path = $self -> { _path };
	my $fh = $self -> { _fh };

	if( ! defined $path) {
		$fh -> open(">&STDOUT");	# default output
	}
	else {

		my $lock = ak::lock -> acquire(
			path => "$path.ll",
			permissions => $self -> {_lock_perm},
		);
		if ( -e $path ) {
			my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime,
				$mtime,$ctime,$blksize,$blocks) = stat($path);
			my $big=3145728; #3Mb
			if ($size > $big) {
				my $p5 = $path . '.5';
				my $p4 = $path . '.4';
				my $p3 = $path . '.3';
				my $p2 = $path . '.2';
				my $p1 = $path . '.1';

				move($p4, $p5) if -e $p4;
				move($p3, $p4) if -e $p3;
				move($p2, $p3) if -e $p2;
				move($p1, $p2) if -e $p1;
				move($path, $p1);
			}
		}
		$lock -> release,

		$fh -> open(">> $path") || croak "$package:$filename:$line: " .
			"Can not open the log \"$path\": $!";

		my $fd = $fh -> fileno;
		open STDERR, ">&$fd";
	}

	$fh -> autoflush;

	$self -> { _opened } = 1;

	return $self;
}

sub set_debug_level {
	my ($self, $lvl) = @_;

	$self -> open if ! $self -> { _opened }  &&
		$lvl > $self -> { _debug_level }; # open if not opened and lvl was 0

	$self -> {_debug_level} = $lvl;
}

sub put {
	my ($self, $lvl, $txt) = @_;
	if ( $self -> { _opened } ) {
		print { $self -> {_fh} } "$txt" if($lvl <= $self -> {_debug_level});
	}
}

sub close{
	my ($self) = @_;
	my ($package, $filename, $line, $subr, $has_args, $wantarray) = caller(0);

	if( $self -> { _opened} ) {
		my $divider = $self -> { _divider };
		$self ->put (1, $divider);
		my $path = $self -> { _path };
		my $fh = $self -> { _fh };
		close($fh) || carp("$package:$filename:$line: Can not close log " .
			"$path: $!");
		#$self -> { _fh } -> close;

		$self -> { _opened } = '';

		if ( -o $path ) {
			my $permissions = $self -> { _permissions };
			my $count = chmod $permissions, $path;
			carp "$package:$filename:$line: Can not setup permissions " .
				"$permissions for log $path: $!" unless $count;
		}
	}
}

1;

