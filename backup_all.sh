#!/bin/bash
gdrive_folder_id=$(cat config.json | jq -r '.gdrive_folder_id')
misskey_server_url=$(cat config.json | jq -r '.misskey_server_url')
misskey_api_key=$(cat config.json | jq -r '.misskey_api_key')
misskey_directory_path=$(cat config.json | jq -r '.misskey_directory_path')
ai_memory_path=$(cat config.json | jq -r '.ai_memory_path')
files_path=$(cat config.json | jq -r '.files_path')

d=$(date)
filename_date=${d// /_}
backup_directory=/tmp/misskey_backup_$filename_date
mkdir -p $backup_directory

cd $misskey_directory_path

# backup ai
echo "Backing up AI memory..."
cp $ai_memory_path $backup_directory/ai_memory_${filename_date}.json

#  backup db
echo "Backing up database..."
sudo docker compose exec -T db bash -c "pg_dump -Fc -U example-misskey-user -d misskey > /var/lib/postgresql/data/misskey_db.dump"
filepath=$misskey_directory_path/misskey_db_${filename_date// /_}.dump
sudo mv $misskey_directory_path/db/misskey_db.dump $backup_directory/$filepath

# backup redis
echo "Backing up Redis data..."
sudo cp $misskey_directory_path/redis/dump.rdb $backup_directory/dump_${filename_date}.rdb

# backup files
echo "Backing up files..."
sudo zip -r $backup_directory/$files_path.zip $files_path

# zip all backups
echo "Creating zip archive of all backups..."
sudo zip -r $backup_directory/misskey_backup_${filename_date}.zip $backup_directory

# upload to gdrive
echo "Uploading backups to Google Drive..."
sudo gdrive files upload --parent $gdrive_folder_id $backup_directory/misskey_backup_${filename_date}.zip

# clean up
echo "Cleaning up local backup files..."
sudo rm -rf $backup_directory
sudo rm -rf $backup_directory/misskey_backup_${filename_date}.zip

# notify completion
curl -XPOST -H 'Content-Type:application/json' -d "{\"i\":\"$misskey_api_key\",\"text\":\"$(date)\nBackup completed\"}" $misskey_server_url/api/notes/create
