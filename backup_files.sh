#!/bin/bash
gdrive_folder_id=$(cat config.json | jq -r '.gdrive_folder_id')
misskey_server_url=$(cat config.json | jq -r '.misskey_server_url')
misskey_api_key=$(cat config.json | jq -r '.misskey_api_key')
files_path=$(cat config.json | jq -r '.files_path')
sudo zip -r $files_path.zip $files_path
sudo gdrive files upload --parent $gdrive_folder_id $files_path.zip
sudo rm -rf $files_path.zip
curl -XPOST -H 'Content-Type:application/json' -d "{\"i\":\"$misskey_api_key\",\"text\":\"$(date)\nFiles backup completed\"}" $misskey_server_url/api/notes/create
