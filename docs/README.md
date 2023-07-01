(UNIX / Linux / Windows) automated installation kit.

## Installation

An unattended installation is performed by specifying a command in installation menu of OS distribution.

### RHEL / Fedora

```ini
inst.ks=https://uaik.github.io/install/os/type/id.ini
```

### Debian / Ubuntu

```ini
url=https://uaik.github.io/install/os/type/id.ini
```

## Users / Passwords

- User: `root`  
  Password: `cDFy mu2a ML`
- User: `user-0000`  
  Password: `7Jxs 6PKV Ak`

**Passwords typed without spaces! Change passwords after installation!**

## First steps

1. Change `root` password.
2. Add new user.
3. Lock default user `user-0000`.

### Download & run "First steps" setup script

```sh
$ curl -sL 'https://uaik.github.io/unix.setup.sh' | bash -
```

## Scripts

- Alma Linux
  - Server
    - [BIOS](install/linux/alma/srv.bios.ini)
    - [UEFI](install/linux/alma/srv.uefi.ini)
- Debian
  - Server
    - [BIOS](install/linux/debian/srv.bios.ini)
    - [UEFI](install/linux/debian/srv.uefi.ini)
  - Workstation
    - [BIOS](install/linux/debian/ws.bios.ini)
    - [UEFI](install/linux/debian/ws.uefi.ini)
- Fedora
  - Server
    - [BIOS](install/linux/fedora/srv.bios.ini)
    - [UEFI](install/linux/fedora/srv.uefi.ini)
  - Workstation
    - [BIOS](install/linux/fedora/ws.bios.ini)
    - [UEFI](install/linux/fedora/ws.uefi.ini)
- Oracle Linux
  - Server
    - [BIOS](install/linux/oracle/srv.bios.ini)
    - [UEFI](install/linux/oracle/srv.uefi.ini)
- Rocky Linux
  - Server
    - [BIOS](install/linux/rocky/srv.bios.ini)
    - [UEFI](install/linux/rocky/srv.uefi.ini)
- [MS Windows](https://github.com/uaik/uaik.github.io/tree/main/docs/install/windows)
- [All scripts](https://github.com/uaik/uaik.github.io/tree/main/docs/install)
