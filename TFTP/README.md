TFTP directory for PXE files
============================

This is the directory for setting tftp server for VirtualBox.
It depends on the host OS and should be in the directory where the file
`VirtualBox.xml` lives. It could be found

`find -L ~ -type f -name VirtualBox.xml 2>/dev/null`

`/Users/alexk/Library/VirtualBox/VirtualBox.xml`

So for my environment (mac os x) the following directory should be created:

`mkdir ~/Library/VirtualBox/TFTP`

This directory should contain files like `vmName.pxe` PXE boot file for VM
with the name `vmName`.

When VM, lets say, `cent`, has *System* - *Boot Order* property `Network`,
and VM is being started the PXE bootloader will try to download `cent.pxe`
file from this directory and transfer the control to it.

If all network bootable VMs are the same, like CentOS 7, it is possible to
copy to `TFTP` directory just one file `pxelinux.0` and for every VM using this PXE file run

`VBoxManage modifyvm cent --nattftpfile1 /pxelinux.0`
 
PXE file `pxelinux.0` could be extracted, for example, from 
[syslinux-4.05-12.el7.x86_64.rpm] (http://mirror.optus.net/centos/7/os/x86_64/Packages/syslinux-4.05-12.el7.x86_64.rpm).

Good explanation could be found [here]
(https://gist.github.com/jtyr/816e46c2c5d9345bd6c9).

