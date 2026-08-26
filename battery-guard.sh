#!/data/data/com.termux/files/usr/bin/bash
# battery-guard.sh — pauses/resumes the tmux-backgrounded xmrig session based
# on battery level and charging state. Requires the `termux-api` package
# (pkg install termux-api) and the Termux:API app installed alongside Termux.
#
# Usage: bash battery-guard.sh &
# Stop it with: kill %1   (or find the PID and kill it)

set -euo pipefail

SESSION="xmrig"
MIN_BATTERY="${MIN_BATTERY:-20}"      # pause mining below this %
REQUIRE_CHARGING="${REQUIRE_CHARGING:-1}"  # 1 = only mine while plugged in
CHECK_INTERVAL="${CHECK_INTERVAL:-60}" # seconds between checks

if ! command -v termux-battery-status >/dev/null 2>&1; then
  echo "termux-battery-status not found. Install with: pkg install termux-api" >&2
  exit 1
fi

paused=0

while true; do
  status_json="$(termux-battery-status)"
  pct=$(echo "$status_json" | grep -o '"percentage": *[0-9]*' | grep -o '[0-9]*')
  state=$(echo "$status_json" | grep -o '"status": *"[A-Z]*"' | grep -o '"[A-Z]*"$' | tr -d '"')

  charging_ok=1
  if [ "$REQUIRE_CHARGING" = "1" ] && [ "$state" != "CHARGING" ] && [ "$state" != "FULL" ]; then
    charging_ok=0
  fi

  if [ "$pct" -lt "$MIN_BATTERY" ] || [ "$charging_ok" -eq 0 ]; then
    if [ "$paused" -eq 0 ] && tmux has-session -t "$SESSION" 2>/dev/null; then
      tmux send-keys -t "$SESSION" "" ""   # no-op keepalive
      tmux send-keys -t "$SESSION" C-z
      paused=1
      echo "[battery-guard] Paused mining (battery=${pct}% state=${state})"
    fi
  else
    if [ "$paused" -eq 1 ] && tmux has-session -t "$SESSION" 2>/dev/null; then
      tmux send-keys -t "$SESSION" "fg" Enter
      paused=0
      echo "[battery-guard] Resumed mining (battery=${pct}% state=${state})"
    fi
  fi

  sleep "$CHECK_INTERVAL"
done
