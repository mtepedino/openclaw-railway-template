#!/bin/bash
set -e

chown -R openclaw:openclaw /data
chmod 700 /data

if [ ! -d /data/.linuxbrew ]; then
  cp -a /home/linuxbrew/.linuxbrew /data/.linuxbrew
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew

# Copy workspace default files into the workspace if they don't exist yet.
# This lets deployments ship default agent personalities, knowledge, and
# configuration without overwriting user-edited files already stored on the
# persistent volume.
SOULS_SOURCE="/app/souls"
WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-/data/workspace}"
if [ -d "$SOULS_SOURCE" ]; then
  mkdir -p "$WORKSPACE_DIR"
  find "$SOULS_SOURCE" -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d '' src; do
    dest_name="$(basename "$src")"
    dest="$WORKSPACE_DIR/$dest_name"
    if [ -e "$dest" ]; then
      continue
    fi
    cp -a "$src" "$dest"
    chown -R openclaw:openclaw "$dest"
  done
fi

exec gosu openclaw node src/server.js
