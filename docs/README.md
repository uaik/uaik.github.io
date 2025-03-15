Набор для автоматической установки и настройки ОС.

## Linux

- RHEL / Fedora:

```ini
inst.ks=https://uaik.github.io/os/[os.type.id.ini]
```

- Debian / Ubuntu:

```ini
url=https://uaik.github.io/os/[os]/[config.ini]
```

### Пользователи

- `root:cDFymu2aML`
- `u0000:7Jxs6PKVAk`

### Конфигурация

- Настройка системы:

```sh
curl -sL 'https://uaik.github.io/config.00.sh' | bash -s
```

- Установка и настройка сервисов:

```sh
curl -sL 'https://uaik.github.io/config.01.sh' | bash -s -- 'pkgmgr;ssh;nft;tmux;sysctl;systemd'
```

## MS Windows

### Пользователи

- `Administrator`
  - Пароль: `cDFymu2aML`
  - Группа: `Administrators`
- `u0000`
  - Пароль: `7Jxs6PKVAk`
  - Группа: `Administrators`
- `u0001`
  - Пароль: `7Jxs6PKVAk`
  - Группа: `Users`
- `u0002`
  - Пароль: `7Jxs6PKVAk`
  - Группа: `Users`

## Скрипты

- [OS](https://github.com/uaik/uaik.github.io/tree/main/docs/os)
