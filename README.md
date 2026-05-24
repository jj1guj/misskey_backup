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
