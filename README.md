This is an extension for Drive Badger. It provides a so called hook script, that:

- scans given directory tree for `/etc/fstab` file
- analyzes its entries
- extracts all statically defined `smbfs`/`cifs` and `nfs` shares
- tries to mount and exfiltrate them

Why this is done during the attack, and not later? Because:

- access to these shares can be restricted to IP address of the exfiltrated computer/server
- almost certainly it is restricted to internal LAN
- almost certainly each mounting is logged - to this is a good way to cover the tracks

### Installing

Clone this repository as `/opt/drivebadger/hooks/hook-fstab` directory on your Drive Badger persistent partition.

### More information

- [Drive Badger main repository](https://github.com/drivebadger/drivebadger)
- [Drive Badger wiki](https://github.com/drivebadger/drivebadger/wiki)
- [description, how hook repositories work](https://github.com/drivebadger/drivebadger/wiki/Hook-repositories)
