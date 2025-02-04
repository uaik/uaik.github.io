Universal automated installation kit.

## Installation

An unattended installation is performed by specifying a command in installation menu of OS distribution.

### RHEL / Fedora

```
inst.ks=https://uaik.github.io/os/[os.type.id.ini]
```

### Debian / Ubuntu

```
url=https://uaik.github.io/os/[os]/[config.ini]
```

## Users / Passwords

- User: `root`  
  Password: `cDFy mu2a ML`
- User: `u0000`  
  Password: `7Jxs 6PKV Ak`

**Passwords typed without spaces! Change passwords after installation!**

## First steps

1. Change `root` password.
2. Add new users.
3. Lock default user `u0000`.

### Download & run configuration script

```sh
curl -sL 'https://uaik.github.io/config.00.sh' | bash -s
```

```sh
curl -sL 'https://uaik.github.io/config.01.sh' | bash -s -- 'pkgmgr;ssh;nft;tmux;sysctl;systemd'
```

#### Apache HTTPD / Nginx / PHP

```sh
curl -sL 'https://uaik.github.io/config.01.sh' | bash -s -- 'httpd;nginx;php'
```

## Scripts

- [OS](https://github.com/uaik/uaik.github.io/tree/main/docs/os)
