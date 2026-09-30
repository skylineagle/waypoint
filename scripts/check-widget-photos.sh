#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
swiftc Shared/AppSettings.swift Shared/TodaySnapshot.swift Shared/WidgetPhotoStore.swift TrekCompanion/TrekURL.swift Checks/WidgetPhotos/main.swift -o "$work/check"
"$work/check"
