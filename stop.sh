#!/data/data/com.termux/files/usr/bin/bash
# stop.sh — stop the miner started by start.sh (foreground or tmux background).
set -euo pipefail

SESSION="xmrig"

if command -v tmux >/dev/null 2>&1 && tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux send-keys -t "$SESSION" C-c
  sleep 1
  tmux kill-session -t "$SESSION" 2>/dev/null || true
  echo "Stopped tmux session '$SESSION'."
else
  if pkill -x xmrig; then
    echo "Stopped xmrig process."
  else
    echo "No running xmrig process found."
  fi
fi

if command -v termux-wake-unlock >/dev/null 2>&1; then
  termux-wake-unlock
  echo "Wake lock released."
fi
