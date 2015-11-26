This directory is for perl scripts.
They are being stored under the name file.sh

Running

make all # for all scripts or
make file

will check perl syntax for all (or just file.sh) files; will make file
executable and store it in ~/bin directory.

The home file system could be NFS and in this case the same home on many
computers.
Different computers may have different perl environments and even the same
computer may have a few different perl environments.

Running the perl script from ~/bin will use first perl found in the PATH.
And the shell should setup the proper PATH for the proper perl to be
used for the perl script in ~/bin.

