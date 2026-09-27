#!/usr/bin/env bash
set -euo pipefail

SIMULATOR="${SIMULATOR:-C3B2F576-B8CD-4D35-97C4-4609DEC7FBF5}"
APP="dev.horizon.trekcompanion"
GROUP="group.dev.horizon.trekcompanion"

usage() {
  cat <<USAGE
Simulate "today" for Trek Companion (Debug builds only).

  scripts/sim-day.sh 2026-10-07   jump to a date
  scripts/sim-day.sh next         one day forward
  scripts/sim-day.sh prev         one day back
  scripts/sim-day.sh show         print the simulated date
  scripts/sim-day.sh reset        back to the real date
  scripts/sim-day.sh undone       clear the stops marked Done

Set SIMULATOR=<udid> to target another simulator.
  scripts/sim-timeline.sh 2026-10-07 [simulator]   walk that day's places
USAGE
}

current() {
  xcrun simctl spawn "$SIMULATOR" defaults read "$APP" TodayDate 2>/dev/null || date +%Y-%m-%d
}

relaunch() {
  xcrun simctl launch --terminate-running-process "$SIMULATOR" "$APP" >/dev/null
}

set_day() {
  xcrun simctl spawn "$SIMULATOR" defaults write "$APP" TodayDate "$1"
  relaunch
  echo "Today is now $1"
}

shift_day() {
  set_day "$(date -j -v"$1"d -f %Y-%m-%d "$(current)" +%Y-%m-%d)"
}

case "${1:-}" in
  next) shift_day +1 ;;
  prev) shift_day -1 ;;
  show) current ;;
  reset)
    xcrun simctl spawn "$SIMULATOR" defaults delete "$APP" TodayDate 2>/dev/null || true
    relaunch
    echo "Back to the real date"
    ;;
  undone)
    container="$(xcrun simctl get_app_container "$SIMULATOR" "$APP" "$GROUP")"
    plist="$container/Library/Preferences/$GROUP.plist"
    for key in $(plutil -p "$plist" 2>/dev/null | grep -o '"done-stops-[0-9]*"' | tr -d '"'); do
      plutil -remove "$key" "$plist"
    done
    relaunch
    echo "Cleared Done stops"
    ;;
  [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) set_day "$1" ;;
  *) usage; exit 1 ;;
esac
