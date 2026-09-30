#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
swiftc Shared/AppGroup.swift JourneyShared/JourneySession.swift JourneyShared/JourneyDestination.swift JourneyShared/JourneyUpload.swift JourneyShared/JourneyStore.swift JourneyShared/JourneyPhoto.swift JourneyShared/JourneyStop.swift Checks/JourneySharing/main.swift -o "$work/check"
"$work/check"
