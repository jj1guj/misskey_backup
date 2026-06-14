#!/bin/bash
misskey_server_url=$(cat config.json | jq -r '.misskey_server_url')
misskey_api_key=$(cat config.json | jq -r '.misskey_api_key')
misskey_directory_path=$(cat config.json | jq -r '.misskey_directory_path')
rclone_config_path=$(cat config.json | jq -r '.rclone_config_path')

echo "Syncing files to Google Drive..."
sudo rclone sync $misskey_directory_path/files gdrive-crypt: --config $rclone_config_path --transfers 4

# notify completion
curl -XPOST -H 'Content-Type:application/json' -d "{\"i\":\"$misskey_api_key\",\"text\":\"$(date)\nFiles backup completed\"}" $misskey_server_url/api/notes/create
