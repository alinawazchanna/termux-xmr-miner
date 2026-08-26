#!/data/data/com.termux/files/usr/bin/bash
# start.sh — launch XMRig using config.json in this directory.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$DIR/config.json"
BIN="$DIR/xmrig"
SESSION="xmrig"

if [ ! -f "$BIN" ]; then
  echo "xmrig binary not found. Run install.sh first." >&2
  exit 1
fi

if [ ! -f "$CONFIG" ]; then
  echo "config.json not found. Copy config.example.json to config.json and fill in your wallet/pool." >&2
  exit 1
fi

if command -v termux-wake-lock >/dev/null 2>&1; then
  termux-wake-lock
  echo "Wake lock acquired (install termux-api package if this failed silently)."
fi

if [ "${1:-}" = "--background" ]; then
  if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux not installed. Run: pkg install tmux" >&2
    exit 1
  fi
  tmux new-session -d -s "$SESSION" "$BIN -c $CONFIG"
  echo "Started in tmux session '$SESSION'. Attach with: tmux attach -t $SESSION"
else
  exec "$BIN" -c "$CONFIG"
fi
