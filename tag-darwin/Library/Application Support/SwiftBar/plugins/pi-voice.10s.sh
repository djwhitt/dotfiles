#!/usr/bin/env bash

# <xbar.title>pi-voice</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.desc>Show pi-voice (Kokoro TTS) server status and start/stop it</xbar.desc>
# <xbar.dependencies>bash,node,pi-voice</xbar.dependencies>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>

# pi-voice is an npm global (~/.npm-packages/bin) and a `#!/usr/bin/env node`
# script, so it needs node (Homebrew) too. The GUI-launched plugin gets neither
# on PATH by default, so set it explicitly here.
PATH=$HOME/.npm-packages/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH

# The host config's `host` is host.docker.internal (so the in-container Pi
# extension can reach the server). On the host we override with 0.0.0.0: this
# binds all interfaces on start (so the container can reach it), and macOS lets
# us connect to 0.0.0.0 for status/stop too — one value covers both roles.
HOST=0.0.0.0
CONFIG=$HOME/.pi/voice/config.json

PIVOICE=$(command -v pi-voice)

if [[ -z $PIVOICE ]]; then
  echo "🗣⚠️"
  echo "---"
  echo "pi-voice not found on PATH"
  exit 0
fi

# Menu actions are run by SwiftBar directly (not via this script's PATH), so
# each action re-establishes PATH and lets bash expand \$HOME / \$PATH at click.
RUN="PATH=\$HOME/.npm-packages/bin:/opt/homebrew/bin:/usr/local/bin:\$PATH pi-voice"

status=$("$PIVOICE" server status --host "$HOST" 2>&1)

if [[ $status =~ online ]]; then
  running=1
  echo "🗣"
else
  running=0
  echo "🗣⏸"
fi

echo "---"

if (( running )); then
  model=$(echo "$status" | sed -n 's/^Model:[[:space:]]*//p')
  echo "Server online | color=green"
  [[ -n $model ]] && echo "Model: $model"
  echo "---"
  echo "Stop server | shell=/bin/bash param1=-c param2=\"$RUN server stop --host $HOST\" terminal=false refresh=true"
  echo "Restart server | shell=/bin/bash param1=-c param2=\"$RUN server restart --host $HOST\" terminal=false refresh=true"
else
  echo "Server offline | color=gray"
  echo "---"
  echo "Start server | shell=/bin/bash param1=-c param2=\"$RUN server start --host $HOST\" terminal=false refresh=true"
fi

echo "---"
# Read-only config view. Toggle auto-TTS via /voice inside Pi.
if [[ -f $CONFIG ]]; then
  if grep -q '"enabled"[[:space:]]*:[[:space:]]*true' "$CONFIG"; then
    echo "Auto-TTS: on | size=11 color=gray"
  else
    echo "Auto-TTS: off | size=11 color=gray"
  fi
  cfghost=$(sed -n 's/.*"host"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG")
  [[ -n $cfghost ]] && echo "Extension host: $cfghost | size=11 color=gray"
fi
echo "Refresh | refresh=true"
