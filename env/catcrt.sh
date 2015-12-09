# $Id: catcrt.sh,v 1.2 2008/06/06 07:57:52 alexk Exp $
function catcrt {
	if [ -z "$1" ] ; then
		openssl x509 -text
	else
		openssl x509 -text -in $1
	fi
}

