Набор сценариев для автоматической установки и настройки ОС.

## Linux

[Сценарии](https://github.com/uaik/uaik.github.io/tree/main/docs/os) для автоматической установки Linux.

### Установка

- RHEL / Fedora:

```ini
inst.ks=https://uaik.github.io/os/[os.type.id.ini]
```

- Debian / Ubuntu:

```ini
url=https://uaik.github.io/os/[os]/[config.ini]
```

### Пользователи

- ROOT
  - Логин: `root`
  - Пароль: `cDFymu2aML`
- USER-0000
  - Логин: `u0000`
  - Пароль: `7Jxs6PKVAk`

### Конфигурация OS

- Настройка системы:

```bash
curl -sL 'https://uaik.github.io/config.00.sh' | bash -s
```

- Установка и настройка сервисов (OS):

```bash
curl -sL 'https://uaik.github.io/config.01.sh' | bash -s -- 'pkgmgr;ssh;nft;tmux;sysctl;systemd'
```

- Установка и настройка сервисов (Proxmox):

```bash
curl -sL 'https://uaik.github.io/config.01.sh' | bash -s -- 'pkgmgr;ssh;tmux'
```

## MS Windows

[Сценарии](https://github.com/uaik/uaik.github.io/tree/main/docs/os/windows) для интеграции в дистрибутив MS Windows.

### Пользователи

- Administrator
  - Логин: `Administrator`
  - Пароль: `cDFymu2aML`
  - Группа: `Administrators`
- USER-0000
  - Логин: `u0000`
  - Пароль: `7Jxs6PKVAk`
  - Группа: `Administrators`
- USER-0001
  - Логин: `u0001`
  - Пароль: `7Jxs6PKVAk`
  - Группа: `Users`
- USER-0002
  - Логин: `u0002`
  - Пароль: `7Jxs6PKVAk`
  - Группа: `Users`
