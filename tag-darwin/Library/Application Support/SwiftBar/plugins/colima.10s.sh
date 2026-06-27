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
  if [[ -n $DOCKER ]]; then
    running_count=$("$DOCKER" ps -q 2>/dev/null | wc -l | tr -d ' ')
    echo "🐳 $running_count"
  else
    echo "🐳"
  fi
else
  running=0
  echo "🐳⏸"
fi

echo "---"

if (( running )); then
  echo "Colima is running | color=green"

  if [[ -n $DOCKER ]]; then
    echo "$running_count containers running"

    # List every container (running + stopped) with per-container actions.
    # Format: state<TAB>name  (state is "running", "exited", etc.)
    while IFS=$'\t' read -r state name; do
      [[ -z $name ]] && continue
      if [[ $state == running ]]; then
        echo "--🟢 $name | color=green"
        echo "----Stop | shell=\"$DOCKER\" param1=stop param2=\"$name\" terminal=false refresh=true"
        echo "----Restart | shell=\"$DOCKER\" param1=restart param2=\"$name\" terminal=false refresh=true"
        echo "----Logs | shell=\"$DOCKER\" param1=logs param2=--tail param3=100 param4=\"$name\" terminal=true"
      else
        echo "--⚪ $name | color=gray"
        echo "----Start | shell=\"$DOCKER\" param1=start param2=\"$name\" terminal=false refresh=true"
        echo "----Remove | shell=\"$DOCKER\" param1=rm param2=\"$name\" terminal=false refresh=true"
      fi
    done < <("$DOCKER" ps -a --format '{{.State}}'$'\t''{{.Names}}' 2>/dev/null)
  fi

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
