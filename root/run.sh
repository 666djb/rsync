#!/usr/bin/env bashio
# shellcheck shell=bash
set -e

PRIVATE_KEY_FILE=$(bashio::config 'private_key_file')

HOST=$(bashio::config 'remote_host')
USERNAME=$(bashio::config 'username')
FOLDERS=$(bashio::addon.config | jq -r ".folders")

if bashio::config.has_value 'remote_port'; then
  PORT=$(bashio::config 'remote_port')
  bashio::log.info "Use port $PORT"
else
  PORT=22
fi
folder_count=$(echo "$FOLDERS" | jq -r '. | length')
for (( i=0; i<folder_count; i=i+1 )); do

  local=$(echo "$FOLDERS" | jq -r ".[$i].destination")
  remote=$(echo "$FOLDERS" | jq -r ".[$i].source")
  options=$(echo "$FOLDERS" | jq -r ".[$i].options // \"-archive --recursive --compress --delete --prune-empty-dirs\"")
  bashio::log.info "Sync ${remote} -> ${local} with options \"${options}\""
  set -x
  # shellcheck disable=SC2086
  rsync ${options} \
  -e "ssh -p ${PORT} -i ${PRIVATE_KEY_FILE} -oStrictHostKeyChecking=no" \
 "${USERNAME}@${HOST}:${remote}" "$local"
  set +x
done

bashio::log.info "Synced all folders"