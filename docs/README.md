Universal automated installation kit.

## Installation

An unattended installation is performed by specifying a command in installation menu of OS distribution.

### RHEL / Fedora

```
inst.ks=https://uaik.github.io/os/[os.type.id.ini]
```

### Debian / Ubuntu

```
url=https://uaik.github.io/os/[os.type.id.ini]
```

### MikroTik RouterOS

```
/tool fetch url="https://uaik.github.io/os/[os.type.id.rsc]" dst-path="[os.type.id.rsc]"
/tool fetch url="https://curl.se/ca/cacert.pem" dst-path="ros.cacert.pem"
/system reset-configuration no-defaults=yes skip-backup=yes run-after-reset="[os.type.id.rsc]"
/certificate import file-name="ros.cacert.pem" passphrase="" name="ROS"
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

- [OS](https://github.com/uaik/uaik.github.io/tree/main/docs/os)
