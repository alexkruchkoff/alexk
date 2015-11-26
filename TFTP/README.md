This is the directory for setting tftp server for VirtualBox.
It depends on the host OS and should be in the directory where the file
VirtualBox.xml lives. It could be found

find -L ~ -type f -name VirtualBox.xml 2>/dev/null
/Users/alexk/Library/VirtualBox/VirtualBox.xml

So for my environment the following directory should be created:

mkdir ~/Library/VirtualBox/TFTP

