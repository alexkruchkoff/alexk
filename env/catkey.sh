# $Id: catkey.sh,v 1.1 2009/06/23 04:05:51 alexk Exp $
function catkey {
	if [ -z "$1" ] ; then
		openssl rsa -text
	else
		openssl rsa -text -in $1
	fi
}

