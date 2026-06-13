# misskey_backup
Backup script for Misskey

# Requirements
* [gdrive](https://github.com/glotlabs/gdrive)
* [jq](https://jqlang.github.io/jq/)
* [pigz](https://zlib.net/pigz/)

# Usage
1. edit `config.json`
2. run below command

```
bash backup_ai.sh
bash backup_db.sh
bash backup_files.sh
```

# systemd timer for backup_all.sh
Use the included units in `systemd/` to run full backup automatically.

## Schedule
* Jan 1: 04:00
* Other days: 00:00

## Install (user service)
1. Replace `/path/to/misskey_backup` in `systemd/misskey-backup.service` with your actual path.

```bash
mkdir -p ~/.config/systemd/user/
cp systemd/misskey-backup.service ~/.config/systemd/user/
cp systemd/misskey-backup.timer ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now misskey-backup.timer
```

To keep the timer running after logout:
```bash
sudo loginctl enable-linger $USER
```

## Check next runs
```bash
systemctl --user list-timers misskey-backup.timer
```

# Restore from encrypted backup

## Decrypt and extract
Run the following command for a downloaded backup file (`.tar.gz.gpg`).

```bash
mkdir -p /tmp/misskey_restore
gpg --decrypt /path/to/misskey_backup_YYYY-MM-DD.tar.gz.gpg | pigz -d | tar xf - -C /tmp/misskey_restore
```

If prompted, enter the same value configured as `gpg_password` in `config.json`.

Extracted backup data will be available under `/tmp/misskey_restore/`.
