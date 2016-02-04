package ak::lock;
$RCSID='$Id: lock.sh,v 1.12 2007/01/06 05:01:53 alexk Exp $';
my @ID = split / /, $RCSID;
$VERSION = $ID[2];

=head1 NAME

B<ak::lock> - a class for acquiring/releasing locks

=head1 VERSION

This document refers to the $Revision: 1.12 $ of ak::lock, released
on $Date: 2007/01/06 05:01:53 $.

=head1 SYNOPSIS

	use ak::lock;
	$lock = ak::log -> acquire($path, $txt);
	$last_ptr = $lock -> last_msg;
	$lock -> release;

=head1 DESCRIPTION

B<ak::lock> is a class for implementing locks.
Locks could be used to prevent the access of more than one process at
a time.

=head2 Methods

=over 4

=item B<acquire ( > I<path> B<,> I<text> B<)>

Acquire a new lock with the I<path>.
Store I<text> in the lock.

=item last_msg

Returns the text stored in the lock before it was acquired.

=item release

Release the lock.

=back

=head1 DIAGNOSTICS

=over 4

=item "Can not open the lock" I<path>

The reason why the lock I<path> could not be opened

=back

=head1 AUTHOR

Alexander Kruchkoff ( alexk (at) users.sf.net )

=cut

use strict;
use FileHandle;
use Fcntl qw(:flock);
use Carp;

sub acquire {
	my ($class, %params) = @_;

	my ($package, $filename, $line, $subr, $has_args, $wantarray) =
		caller(0);
	croak "$package:$filename:$line: Do not know what to lock: please " .
		"provide the path" unless exists $params{"path"};

	my $path = $params{"path"};
	my $txt = exists($params{"txt"}) ? $params{"txt"} : "locked by $$\n";
	my $permissions = exists($params{"permissions"}) ?
		$params{"permissions"} : 0664 ;
	my $fh = FileHandle -> new ;

	sysopen($fh, $path, O_RDWR|O_CREAT) ||
		croak("$package:$filename:$line: Can not open the lock $path: $!");

	flock($fh, LOCK_EX) ||
		croak("$package:$filename:$line: Can not lock the lock $path: $!");

	chomp(my @last = <$fh>);

	seek($fh, 0, 0) ||
		croak("$package:$filename:$line: Can not rewind the lock $path: " .
			$!);
	truncate($fh, 0) ||
		croak("$package:$filename:$line: Can not truncate the lock " .
			"$path: $!");

	print $fh $txt;
	
	my $lock = bless {
		_path => $path,
		_fh => $fh,
		_permissions => $permissions,
		_last => \@last,
	}, $class;

	return $lock;
}

sub last_msg {
	my ($self) = @_;
	return $self -> { _last };
}

sub release {
	my ( $self ) = @_;
	my $fh = $self -> { _fh };
	my ($package, $filename, $line, $subr, $has_args, $wantarray) =
		caller(0);
	print $fh "done\n";
	my $path = $self -> { _path };
	close($fh) || croak("$filename:$line:" .
		" Can not release the lock $path: $!");
	if ( -o $path ) {
		my $permissions = $self -> { _permissions };
		my $count = chmod $permissions, $path;
		carp "$package:$filename:$line: Can not setup permissions " .
			"$permissions for lock $path: $!" unless $count;
	}
}

1;

