# misskey_backup
Backup script for Misskey

# Requirements
* [rclone](https://rclone.org/)
* [jq](https://jqlang.github.io/jq/)
* [pigz](https://zlib.net/pigz/)

# Setup

## 1. config.json
Edit `config.json` with your environment settings.

## 2. rclone setup

### Google Drive remote

```bash
rclone config
```

1. `n` → New remote
2. name: `gdrive`
3. Storage: `Google Drive`
4. client_id / client_secret: leave empty
5. scope: `1` (Full access)
6. service_account_file: leave empty
7. Advanced config: `n`
8. Auto config: `n` (for remote servers)
9. Run `rclone authorize "drive" "<displayed token>"` on a local machine with a browser, then paste the result
10. Team Drive: `n` (for personal drives)

### Encrypted remote (crypt)

Continue with `rclone config`:

1. `n` → New remote
2. name: `gdrive-crypt`
3. Storage: `Encrypt/Decrypt a remote` (crypt)
4. remote: `gdrive:<your_backup_dir>/files`
5. filename_encryption: `standard`
6. directory_name_encryption: `true`
7. password: enter a passphrase (**make sure to save this; losing it makes decryption impossible**)
8. password2 (salt): recommended (**save this as well**)
9. Advanced config: `n`

### Protect config file

```bash
chmod 600 ~/.config/rclone/rclone.conf
```

### Verify setup

```bash
rclone lsd gdrive:<your_backup_dir>
sudo rclone sync --dry-run /path/to/misskey/files gdrive-crypt: --config /path/to/.config/rclone/rclone.conf
```

### Initial sync

The initial sync transfers all files and may take several hours. Run inside `tmux`.

```bash
tmux
sudo rclone sync /path/to/misskey/files gdrive-crypt: --config /path/to/.config/rclone/rclone.conf --transfers 4 --progress
```

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
