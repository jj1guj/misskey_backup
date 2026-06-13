#!/bin/bash
gdrive_folder_id=$(cat config.json | jq -r '.gdrive_folder_id')
misskey_server_url=$(cat config.json | jq -r '.misskey_server_url')
misskey_api_key=$(cat config.json | jq -r '.misskey_api_key')
misskey_directory_path=$(cat config.json | jq -r '.misskey_directory_path')
ai_memory_path=$(cat config.json | jq -r '.ai_memory_path')
gpg_password=$(cat config.json | jq -r '.gpg_password')

d=$(date)
filename_date=${d// /_}
backup_directory=/tmp/misskey_backup_$filename_date
backup_gpg=/tmp/misskey_backup_${filename_date}.tar.gz.gpg
mkdir -p $backup_directory

cd $misskey_directory_path

# backup ai
echo "Backing up AI memory..."
cp $ai_memory_path $backup_directory/ai_memory_${filename_date}.json

#  backup db
echo "Backing up database..."
sudo docker compose exec -T db bash -c "pg_dump -Fc -U example-misskey-user -d misskey > /var/lib/postgresql/data/misskey_db.dump"
filepath=misskey_db_$filename_date.dump
sudo mv $misskey_directory_path/db/misskey_db.dump $backup_directory/$filepath

# backup redis
echo "Backing up Redis data..."
sudo cp $misskey_directory_path/redis/dump.rdb $backup_directory/dump_${filename_date}.rdb

# archive, compress, and encrypt all backups (including files) in one pipeline
echo "Creating compressed and encrypted backup archive..."
sudo tar cf - -C /tmp misskey_backup_$filename_date -C $misskey_directory_path files \
  | pigz -p 2 \
  | gpg --batch --yes --pinentry-mode loopback --passphrase "$gpg_password" --symmetric --cipher-algo AES256 --output $backup_gpg

# upload to gdrive
echo "Uploading backups to Google Drive..."
sudo gdrive files upload --parent $gdrive_folder_id $backup_gpg

# clean up
echo "Cleaning up local backup files..."
sudo rm -rf $backup_directory
sudo rm -f $backup_gpg

# notify completion
curl -XPOST -H 'Content-Type:application/json' -d "{\"i\":\"$misskey_api_key\",\"text\":\"$(date)\nBackup completed\"}" $misskey_server_url/api/notes/create
