#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
swiftc Shared/StopCategory.swift Shared/StopHere.swift Shared/TripJourney.swift Shared/AppSettings.swift Shared/TodaySnapshot.swift Shared/WidgetPhotoStore.swift TrekCompanion/TrekURL.swift Checks/WidgetPhotos/main.swift -o "$work/check"
"$work/check"
