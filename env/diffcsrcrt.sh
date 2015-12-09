# $Header: /cvs/env/alexk/diffcsrcrt.sh,v 1.2 2009/10/21 23:41:13 alexk Exp $
function diffcsrcrt {
	if [ $# -ne 2 ]; then
		echo Usage: diffcsrcrt file.csr file.crt
		return 1
	fi

	CSR=$1
	CRT=$2
	PID=$$

	openssl req -noout -text -in $CSR -modulus | grep ^Modulus > $CSR.$PID
	openssl x509 -noout -text -in $CRT -modulus | grep ^Modulus > $CRT.$PID

	diff $CSR.$PID $CRT.$PID

	rm -f $CSR.$PID $CRT.$PID 
}

