# $Id: catcsr.sh,v 1.1 2008/04/22 04:41:28 alexk Exp $
function catcsr {
	if [ -z "$1" ] ; then
		openssl req -text
	else
		openssl req -text -in $1
	fi
}

