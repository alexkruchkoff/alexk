=head1 NAME

B<mkloginyaml> is the script to generate accounts yaml file

=head1 SYNOPSIS

B<mkloginyaml> file

=head1 DESCRIPTION

B<mkloginyaml> script is being called with one parameter C<file>.
It is assumed that the file contains part of /etc/passwd from another server
with required accounts.
It is also assumed that the current working directory contains files with
public ssh keys named C<key.>I<login>.
The script prints generated yaml file to the STDOUT.

=cut

use warnings;
use Getopt::Std;

sub fromFile {
	my ($file) = @_;
	open(FILE, "<", "$file") or die "Can not read \"$file\": $!\n";
	chomp(my @lines = <FILE>);
	close FILE;
	return unless defined wantarray;
	return wantarray ? @lines : join("\n",@lines);
}

my ($file) = @ARGV;
my @accounts = fromFile $file;

print << "EOF";
---
# This file contains the information about accounts to be created.
# Each account contains:
# login:
# id: -- it is assumed the same uid and gid
# comment:
# key: ssh public key
accounts: &accounts
EOF
for my $u (@accounts) {
	my @fields = split /:/, $u;
	print "  - login:   $fields[0]\n    id:      $fields[2]\n" .
		"    comment: '$fields[4]'\n";

	my $key = "key.$fields[0]";
	my @lines = fromFile $key;
	print "    key:     '" . $lines[-1] . "'\n\n";
}

print "\n";

