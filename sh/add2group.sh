#!/bin/bash

# add every every member of group1 to group2

if [ ${EUID} -ne 0 ]; then
	echo You must be root to run $0 >&2
	exit 1
fi

if [ $# -ne 2 ]; then
	echo "Usage: $0 group1 group2" >&2
	exit 2
fi

GETENT=/usr/bin/getent
AWK=/usr/bin/awk
SED=/usr/bin/sed
ID=/usr/bin/id

group1=$1;
group2=$2;

#echo \"$group1\" \"$group2\"


group1info=`${GETENT} group "$group1"` || {
	echo ERROR $? with obtaing info about group \"$group1\" >&2 
	exit 3
}

group2info=`${GETENT} group "$group2"` || {
	echo ERROR $? with obtaing info about group \"$group2\" >&2
	exit 4
}

echo processing users from the group \"$group1\"... >&2

for user in `echo $group1info | ${AWK} -F: '{print $4}' | ${SED} -e 's|,| |g'`
do
	echo -n checking $user ... >&2
	${ID} -a "$user" | grep "$group2" >/dev/null && echo $user alteady belongs to the group \"$group2\" >&2 || groupmems -a $user -g $group2

done

