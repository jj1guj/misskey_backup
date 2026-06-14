# misskey_backup
Backup script for Misskey

# Requirements
* [gdrive](https://github.com/glotlabs/gdrive)
* [rclone](https://rclone.org/)
* [jq](https://jqlang.github.io/jq/)

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

## Manual execution

```bash
bash backup_core.sh    # DB, Redis, AI memory
bash backup_files.sh   # Media files (rclone sync)
```

Individual backup scripts are also available:

```bash
bash backup_ai.sh
bash backup_db.sh
```

# systemd timers

Two separate services are provided:

| Service | Description |
|---|---|
| `misskey-backup-core` | DB, Redis, AI memory → zip → gpg → gdrive upload |
| `misskey-backup-files` | Media files → rclone sync (encrypted) |

## Schedule
* Jan 1: 04:00
* Other days: 00:00

## Install (user service)
1. Replace `/path/to/misskey_backup` in service files with your actual path.

```bash
mkdir -p ~/.config/systemd/user/
cp systemd/misskey-backup-core.service ~/.config/systemd/user/
cp systemd/misskey-backup-core.timer ~/.config/systemd/user/
cp systemd/misskey-backup-files.service ~/.config/systemd/user/
cp systemd/misskey-backup-files.timer ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now misskey-backup-core.timer
systemctl --user enable --now misskey-backup-files.timer
```

To keep the timers running after logout:
```bash
sudo loginctl enable-linger $USER
```

## Check next runs
```bash
systemctl --user list-timers misskey-backup-core.timer misskey-backup-files.timer
```

# Restore

## Core backup (DB, Redis, AI memory)

Download the `.zip.gpg` file from Google Drive, then:

```bash
gpg --output misskey_backup_restore.zip --decrypt /path/to/misskey_backup_YYYY-MM-DD.zip.gpg
mkdir -p /tmp/misskey_restore
unzip -q misskey_backup_restore.zip -d /tmp/misskey_restore
```

If prompted, enter the same value configured as `gpg_password` in `config.json`.

Extracted backup data will be available under `/tmp/misskey_restore/`.

## Files backup (media files)

Restore encrypted files from Google Drive using rclone:

```bash
sudo rclone sync gdrive-crypt: /path/to/misskey/files --config /path/to/.config/rclone/rclone.conf --transfers 4 --progress
```

This requires the same rclone crypt configuration (passwords) used during backup.
