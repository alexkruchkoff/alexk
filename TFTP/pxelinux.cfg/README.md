TFTP/pxelinux.cfg directory
===========================

When the VM is being booted by the bootloader `/pxelinux.0` -- it will try
to download the menu file from this directory.

First, `/pxelinux.0` will try to download the file with the name of VM UUID,
like `/pxelinux.cfg/cfc1dff9-0324-4713-b9db-d5739b47d3b0` for VM `cent` with

`UUID:            cfc1dff9-0324-4713-b9db-d5739b47d3b0`.

If file with such name is not accessible (like it does not exist or it has
wrong permissions), then there is an attempt to download the file with the
name 01-*MAC*, like for VM `cent` with MAC: 080027BE1529 the bootloader will
try to download the file with the name `/pxelinux.cfg/01-08-00-27-be-15-29`.

If the menu file with the name created from MAC address as above is not
accessible then the boot loader will try to download the menu file based
on ip address (which has been received from dhcp server earlier).
For ip address `10.0.2.15` which is `0A 00 02 0F` in hex the boot loader
will try to download the file with the name `/pxelinux.cfg/0A00020F`.

If the file with the name `/pxelinux.cfg/0A00020F` is not accessible then
the boot loader will repeat attempts to downloadg the menu file with
removing last hex digit:

  * '/pxelinux.cfg/0A00020'
  * '/pxelinux.cfg/0A0002'
  * '/pxelinux.cfg/0A000'
  * '/pxelinux.cfg/0A00'
  * '/pxelinux.cfg/0A0'
  * '/pxelinux.cfg/0A'
  * '/pxelinux.cfg/0'

If attempts to download the menu file in such order would be unsuccessful,
the boot loader will try to download the menu file ``/pxelinux.cfg/default`.
And if the file `/pxelinux.cfg/default` is not accessible then the attempt
to boot from the network would be aborted with an error: No bootable medium
found.

