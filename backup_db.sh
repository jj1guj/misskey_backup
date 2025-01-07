#!/bin/bash
gdrive_folder_id=$(cat config.json | jq -r '.gdrive_folder_id')
misskey_server_url=$(cat config.json | jq -r '.misskey_server_url')
misskey_api_key=$(cat config.json | jq -r '.misskey_api_key')
misskey_directory_path=$(cat config.json | jq -r '.misskey_directory_path')
cd $misskey_directory_path
sudo docker compose exec -T db bash -c "pg_dump -Fc -U example-misskey-user -d misskey > /var/lib/postgresql/data/misskey_db.dump"
filename_date=$(date)
filepath=$misskey_directory_path/misskey_db_${filename_date// /_}.dump
sudo mv $misskey_directory_path/db/misskey_db.dump $filepath
gdrive files upload --parent $gdrive_folder_id $filepath
rm -rf $filepath
curl -XPOST -H 'Content-Type:application/json' -d "{\"i\":\"$misskey_api_key\",\"text\":\"$(date)\nDB backup completed\"}" $misskey_server_url/api/notes/create
