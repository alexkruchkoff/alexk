# start headless vm
function s {
	if [ -z "$1" ]; then
		echo "Usage: $FUNCNAME vm" >&2
		return 1
	else
		/usr/local/bin/VBoxManage startvm "$1" --type headless
	fi
}
