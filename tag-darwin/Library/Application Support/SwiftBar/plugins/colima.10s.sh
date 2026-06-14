#!/usr/bin/env bash

# <xbar.title>Colima</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.desc>Show Colima status and start/stop the container runtime</xbar.desc>
# <xbar.dependencies>bash,colima,docker</xbar.dependencies>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>

# Nix installs colima/docker under /run/current-system/sw/bin, which the
# GUI-launched plugin does not get on PATH by default.
PATH=/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:$PATH

COLIMA=$(command -v colima)
DOCKER=$(command -v docker)

if [[ -z $COLIMA ]]; then
  echo "🐳⚠️"
  echo "---"
  echo "colima not found on PATH"
  exit 0
fi

status=$("$COLIMA" status 2>&1)

if [[ $status =~ "colima is running" ]]; then
  running=1
  echo "🐳"
else
  running=0
  echo "🐳⏸"
fi

echo "---"

if (( running )); then
  echo "Colima is running | color=green"
  [[ -n $DOCKER ]] && echo "$("$DOCKER" ps -q 2>/dev/null | wc -l | tr -d ' ') containers running"
  echo "---"
  echo "Stop Colima | shell=\"$COLIMA\" param1=stop terminal=false refresh=true"
  echo "Restart Colima | shell=\"$COLIMA\" param1=restart terminal=false refresh=true"
else
  echo "Colima is stopped | color=gray"
  echo "---"
  echo "Start Colima | shell=\"$COLIMA\" param1=start terminal=false refresh=true"
fi

echo "---"
echo "$("$COLIMA" version 2>/dev/null | head -1) | size=11 color=gray"
echo "Refresh | refresh=true"
