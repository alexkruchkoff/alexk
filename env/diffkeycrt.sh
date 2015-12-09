# $Header: /cvs/env/alexk/diffkeycrt.sh,v 1.2 2010/11/18 00:48:38 alexk Exp $
function diffkeycrt {
	if [ $# -ne 2 ]; then
		echo Usage: diffkeycrt file.key file.crt
		return 1
	fi

	KEY=$1
	CRT=$2
	PID=$$

	openssl x509 -noout -text -in $CRT -modulus | grep ^Modulus > $CRT.$PID
	openssl rsa -noout -text -in $KEY -modulus | grep ^Modulus > $KEY.$PID

	diff $CRT.$PID $KEY.$PID

	rm -f $CRT.$PID $KEY.$PID 
}

