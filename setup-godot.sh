#!/bin/bash
# setup-godot.sh — installe Godot 4.3 headless pour les sessions Claude Code Remote
set -e

GODOT_VERSION="4.3-stable"
GODOT_BIN="/usr/local/bin/godot"

if [ ! -x "$GODOT_BIN" ]; then
  curl -sSL -o /tmp/godot.zip \
    "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
  cd /tmp && unzip -o godot.zip
  cp "Godot_v${GODOT_VERSION}_linux.x86_64" "$GODOT_BIN"
  chmod +x "$GODOT_BIN"
  rm -f /tmp/godot.zip "/tmp/Godot_v${GODOT_VERSION}_linux.x86_64"
fi

# Generer le cache d'import si absent
if [ ! -d ".godot" ]; then
  godot --headless --import
fi
