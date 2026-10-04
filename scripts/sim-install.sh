#!/bin/sh
# Usage: scripts/sim-install.sh ["18 pro" | "air" | <udid>]   (default: "18 pro")
# Picks the shortest matching simulator name, so "18 pro" beats "18 Pro Max".
set -e
cd "$(dirname "$0")/.."

query="${1:-18 pro}"
match=$(xcrun simctl list devices available | grep -i -- "$query" \
  | sed -E 's/^ *(.*) \(([0-9A-F-]{36})\).*/\1|\2/' | awk '{ print length($0) "|" $0 }' | sort -n | head -1)
[ -n "$match" ] || { echo "No simulator matches \"$query\"" >&2; exit 1; }
name=$(echo "$match" | cut -d'|' -f2)
udid=$(echo "$match" | cut -d'|' -f3)

echo "Installing on $name ($udid)"
xcrun simctl boot "$udid" 2>/dev/null || true
xcodebuild -project TrekCompanion.xcodeproj -scheme TrekCompanion -destination "id=$udid" -derivedDataPath /tmp/trekdd -quiet build
xcrun simctl install "$udid" /tmp/trekdd/Build/Products/Debug-iphonesimulator/TrekCompanion.app
xcrun simctl launch --terminate-running-process "$udid" dev.horizon.trekcompanion
