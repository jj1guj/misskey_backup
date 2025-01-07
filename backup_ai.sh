#!/bin/bash
gdrive_folder_id=$(cat config.json | jq -r '.gdrive_folder_id')
misskey_server_url=$(cat config.json | jq -r '.misskey_server_url')
misskey_api_key=$(cat config.json | jq -r '.misskey_api_key')
ai_memory_path=$(cat config.json | jq -r '.ai_memory_path')
gdrive files upload --parent $gdrive_folder_id $ai_memory_path
curl -XPOST -H 'Content-Type:application/json' -d "{\"i\":\"$misskey_api_key\",\"text\":\"$(date)\n@ai backup completed\"}" $misskey_server_url/api/notes/create
