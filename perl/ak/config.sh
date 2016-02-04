package ak::config;
$RCSID='$Id: config.sh,v 1.18 2007/01/06 05:01:53 alexk Exp $';
my @ID = split / /, $RCSID;
$VERSION = $ID[2];

=head1 NAME

B<ak::config> - a class for parsing a configuration file

=head1 VERSION

This document refers to the $Revision: 1.18 $ of ak::config, released
on $Date: 2007/01/06 05:01:53 $.

=head1 SYNOPSIS

 use ak::config;
 $config = ak::config -> parse(
   path    => '/usr/local/etc/cwconfig.cfg',
   pattern => '=',   # default ':'
   log     => $mylog # optional log: needs only for debugging
 );
 $ptr_to_values = $config -> get($attribute);
 @attr = $config -> attributes;
 for $attr (sort @attr) {
   print "attr=" . $config -> get_string ($attr) . ";\n";
 }
 die "No such value '$value' found for '$attr'\n"
   unless $config -> found(value => $value, for => $attr);

=head1 DESCRIPTION

The module B<ak::config> is used to parse the configuration files.

=cut

use ak::log;
use Carp;

sub array_string {
	return '["' . join('", "',@{$_[0]}) . '"]';
}

sub found_in_array {
	my ($val, $ptr) = @_;
	for my $i (@{$ptr}) {
		return 1 if $val eq $i;
	}
	return '';
}

sub parse {
	my ($class, %params) = @_;
	my ($package, $filename, $line, $subr, $has_args, $wantarray) =
		caller(0);
	croak "$package:$filename:$line: no path defined; try something " .
		"like:\n$config = ak:config -> " .
		"parse(path => \"/usr/local/etc/cwconfig.cfg\", pattern => \":\")"
		unless exists $params{"path"};

	my $log = exists($params{"log"}) ? $params{"log"} :
		ak::log -> new(debug_level => 0);

	my $pattern = exists($params{"pattern"}) ? $params{"pattern"} : ':';

	my $fid = "[ak::config->parse]";
	$log ->put (10, "$fid pattern '$pattern'\n");

	my $self = bless {}, $class;

	open(CONF, $params{"path"}) or croak "$package:$filename:$line: " .
		"Cant open config file $file: $!\n";
	while(<CONF>){
		chomp;
		next if /^\s*#/;
		next if /^\s*$/;
		$log ->put (9, "$fid line '$_'\n");
		my @fields = split /$pattern/;

		if(scalar(@fields) < 2) {
			my $msg = "$fid Error in configuration file line:\n\"$_\"\n" .
				"Ignoring. It should be:\nname$pattern" . "value[$pattern" .
				"value...]\n";
			$log ->put(1, $msg);
			carp $msg;
			next;
		}

		$log ->put (10, "$fid fields '" . join(";\n", @fields) . "'\n");

		my @values = splice @fields, 1;
		$self -> {$fields[0]} = [ @values ];

		$log ->put (10, "$fid field(0)=" . $fields[0] .
			"; values '" . join(";\n", @values) . "'\n");
			$log ->put (7, "$fid f0 $fields[0]=" .
			array_string($self -> {$fields[0]}) . ";\n");
	}
	close CONF;

	return $self;
}

sub get {
	my ($self, $attrib) = @_;
	return undef unless defined $self -> {$attrib};
	return $self -> {$attrib};
}

sub get_string {
	my ($self, $attrib) = @_;
	return '[]' unless defined $self -> {$attrib};
	return array_string($self -> {$attrib});
}

sub attributes {
	my ($self) = @_;
	return (keys %{$self});
}

sub found {
	my ($self, %params) = @_;
	return '' unless exists $params{"value"};
	return '' unless exists $params{"for"};
	my $ptr_to_values = $self -> {$params{"for"}};
	return found_in_array ($params{"value"}, $ptr_to_values);
}

1;

