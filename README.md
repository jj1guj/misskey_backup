# misskey_backup
Backup script for Misskey

# Requirements
* [gdrive](https://github.com/glotlabs/gdrive)
* [jq](https://jqlang.github.io/jq/)

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

## Install (system service)
1. Replace `/path/to/misskey_backup` in `systemd/misskey-backup.service` with your actual path.
2. Replace `YOUR_USERNAME` in `systemd/misskey-backup.service` with the user who has `gdrive` authenticated (the user whose `~/.config/gdrive/` contains valid tokens).

```bash
sudo cp systemd/misskey-backup.service /etc/systemd/system/
sudo cp systemd/misskey-backup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now misskey-backup.timer
```

## Check next runs
```bash
systemctl list-timers misskey-backup.timer
```

# Restore from encrypted backup

## Decrypt
Run the following command for a downloaded backup file (`.zip.gpg`).

```bash
gpg --output misskey_backup_restore.zip --decrypt /path/to/misskey_backup_YYYY-MM-DD.zip.gpg
```

If prompted, enter the same value configured as `gpg_password` in `config.json`.

## Extract
```bash
mkdir -p /tmp/misskey_restore
unzip -q misskey_backup_restore.zip -d /tmp/misskey_restore
```

Extracted backup data will be available under `/tmp/misskey_restore/`.
