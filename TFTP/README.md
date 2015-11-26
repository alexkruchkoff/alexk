This is the directory for setting tftp server for VirtualBox.
It depends on the host OS and should be in the directory where the file
`VirtualBox.xml` lives. It could be found

```find -L ~ -type f -name VirtualBox.xml 2>/dev/null

/Users/alexk/Library/VirtualBox/VirtualBox.xml```

So for my environment the following directory should be created:

`mkdir ~/Library/VirtualBox/TFTP`

This directory should contain files like vmName.pxe PXE boot file for VM
with the name vmName.

When VM, lets say, **cent**, has `System` - `Boot Order` property `Network`,
and VM is being started the PXE bootloader will try to download **cent.pxe**
file from this directory and transfer the control to it.

Good explanation could be found [here] (https://gist.github.com/jtyr/816e46c2c5d9345bd6c9).
