package ak::email;
$RCSID='$Id: email.sh,v 1.24 2007/02/08 23:40:18 alexk Exp $';
my @ID = split / /, $RCSID;
$VERSION = $ID[2];

=head1 NAME

B<ak::email> - a class for sending email

=head1 VERSION

This document refers to the $Revision: 1.24 $ of ak::email, released
on $Date: 2007/02/08 23:40:18 $.

=head1 SYNOPSIS

 use ak::log;    # optional for logging only
 use ak::config; # optional for parsing config file only
 use ak::email;

 my $log = ak::log -> new(
   path => "/tmp/my.log",
   debug_level => 4
 );

 my $config = ak::config -> parse(
   path    => '/usr/local/etc/mail_config.cfg',
   log     => $log # optional log: needs only for debugging
 );

 # config file could contain:
 # smtp_host:smtp.domain.name
 # mail_domain:domain.name
 # from_host:my.box.domain.name
 # mail_to:test_account@domain.name

 my $from = "test_email\@" . $config -> get('from_host') -> [0];

 my $result = ak::email -> send (
    config => $config, log => $log, mail_from => $from,
		message => "testing, testing: 1 2 3...",
    subject => 'test',
		debug => 1,    # optional to trace SMTP exchange; by default 0
		html => 1    # optional to send as html; by default 0
 );

 die "could not send email\n" unless defined $result;

 $log -> put (4, "ak::email -> send result=$result;\n");
 $log -> close;

=head1 DESCRIPTION

The module B<ak::email> is for sending email.

=cut

use ak::config;
use Net::SMTP;
use Carp;

sub send {
	my ($class, %params) = @_;

	my ($package, $filename, $line, $subr, $has_args, $wantarray) =
		caller(0);

	my $log = exists($params{"log"}) ? $params{"log"} :
		ak::log -> new(debug_level => 0);

	my $config = exists($params{"config"}) ? $params{"config"} :
		(exists($params{"config_path"}) ?
		ak::config -> parse (
			path => $params{"config_path"},
			pattern => (exists($params{"config_pattern"}) ?
				$params{"config_pattern"} : ':'),
			log => $log) :
		undef);

	my @parameters = qw(mail_from mail_to mail_domain smtp_host);
	my %parameters = ();
	my %array = ();
	for my $parameter (@parameters) {
		$array{$parameter} = '';
	}
	$array{"mail_to"} = 1;
	
	my @undefined = ();
	for my $parameter (@parameters) {
		$log -> put(9, "[ak::email->send] parameter=$parameter;\n");

		$parameters{$parameter} = exists($params{$parameter}) ?
			[ $params{$parameter} ] :
			((defined($config) &&  defined($config -> get($parameter))) ?
				$config -> get($parameter) :
				push(@undefined, $parameter));
	}

	# should be in parameters: if > 10 =1 ?0

	my $n = scalar @undefined;
	croak("$package:$filename:$line: parameter" .
		($n > 1 ? 's ' : ' ') . join(', ', @undefined) .
		($n > 1 ? ' are' : ' is') . " not defined") if $n > 0;

	$parameters{"message"} = exists($params{"message"}) ?
		[ $params{"message"} ] : [ '' ];
	$parameters{"subject"} = exists($params{"subject"}) ?
		[ $params{"subject"} ] : [ '' ];
	$parameters{"debug"} = exists($params{"debug"}) ?
		[ $params{"debug"} ] : [ 0 ];

	for my $parameter (sort keys %parameters) {
		$log -> put(9, "[ak::email->send] parameter:$parameter=[\"" .
			join('", "', (@{$parameters{$parameter}})) . "\"]\n");
	}

	my $smtp = Net::SMTP->new($parameters{'smtp_host'} -> [0],
		Hello => $parameters{'mail_domain'} -> [0],
		Timeout => 30,
		Debug => $parameters{'debug'} -> [0]);
		
	$log -> put(1,"[ak::email->send] Can not make a smtp connection to " .
		$$parameters{'smtp_host'} -> [0] . " using domain " .
		$$parameters{'mail_domain'} -> [0] . ";\n"),
	return unless defined $smtp;

	$log -> put (10, "[ak::email->send] smtp=$smtp;\n");

	my $result = $smtp -> mail($parameters{'mail_from'} -> [0]);

	$log -> put(9, "[ak::email->send] mail result=$result;\n")
		if defined $result;
	$smtp -> quit, $log -> put(1, "[ak::email->send] Can not send " .
		"mail command\n"), return unless defined $result && $result;

	$result = $smtp -> to((@{$parameters{'mail_to'}}), { SkipBad => 1});

	$log -> put(9, "[ak::email->send] to result=$result;\n")
		if defined $result;
	$smtp -> quit, $log -> put(1, "[ak::email->send] Can not use " .
		"method to\n"), return unless defined $result && $result;

	$result = $smtp -> data();
	$log -> put(9, "[ak::email->send] data result=$result;\n")
		if defined $result;
	$smtp -> quit, $log -> put(1, "[ak::email->send] Can not use " .
			"method data\n"), return unless defined $result && $result;

	my $to = "To: " . join(', ', @{$parameters{'mail_to'}}) . "\n";
	$result = $smtp -> datasend($to);

	$log -> put(9, "[ak::email->send] datasend \"$to\" " .
		"result=$result;\n") if defined $result;

	$smtp -> quit,
	$log -> put(1, "[ak::email->send] Can not use method datasend for " .
		"$to\n"), return unless defined $result && $result;

	if(exists($params{"html"}) && $params{"html"}) {
		my $html_header = "Content-type: text/html\n";
		$result = $smtp -> datasend($html_header);

		$log -> put(1, "[ak::email->send] Can not use method datasend for " .
			"$html_header\n"), return unless defined $result && $result;
	}

	my $subject = "Subject: " . $parameters{'subject'} -> [0] .  "\n";
	$result = $smtp -> datasend($subject);

	$log -> put(9, "[ak::email->send] datasend \"$subject\" " .
		"result=$result;\n") if defined $result;
	$smtp -> quit,
	$log -> put(1, "[ak::email->send] Can not use method datasend for " .
		"$subject\n"), return unless defined $result && $result;

	$result = $smtp -> datasend("\n");
	$log -> put(9, "[ak::email->send] datasend result=$result;\n")
		if defined $result;
	$smtp -> quit, $log -> put(1, "[ak::email->send] Can not use " .
		"method datasend\n"), return unless defined $result && $result;

	my $message = $parameters{'message'} -> [0] . "\n";
	$result = $smtp -> datasend($message);
	$log -> put(9, "[ak::email->send] datasend \"$message\" " .
		"result=$result;\n") if defined $result;
	$smtp -> quit,
	$log -> put(1, "[ak::email->send] Can not use method datasend for " .
		"$message\n"), return unless defined $result && $result;

	$result = $smtp -> dataend();
	$log -> put(9, "[ak::email->send] dataend result=$result;\n")
		if defined $result;
	$smtp -> quit, $log -> put(1, "[ak::email->send] Can not use " .
		"method dataend\n"), return unless defined $result && $result;

	$result = $smtp -> quit;
	$log -> put(9, "[ak::email->send] quit result=$result;\n")
		if defined $result;
	$log -> put(1, "[ak::email->send] Can not use method quit\n"),
	return unless defined $result && $result;

	$log -> put(4, "[ak::email->send] the email $to $subject" .
		"\"$message\" has been sent\n");
	
}

1;

