# $Header: /cvs/env/alexk/diffkeycsr.sh,v 1.1 2009/06/29 22:27:51 alexk Exp $
function diffkeycsr {
	if [ $# -ne 2 ]; then
		echo Usage: diffkeycsr file.key file.csr
		return 1
	fi

	KEY=$1
	CSR=$2
	PID=$$

	openssl req -noout -text -in $CSR -modulus | grep ^Modulus > $CSR.$PID
	openssl rsa -noout -text -in $KEY -modulus | grep ^Modulus > $KEY.$PID

	diff $CSR.$PID $KEY.$PID

	rm -f $CSR.$PID $KEY.$PID 
}

