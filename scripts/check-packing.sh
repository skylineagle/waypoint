#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
swiftc -parse-as-library TrekCompanion/PackingItem.swift TrekCompanion/PackingBag.swift Checks/Packing/main.swift -o "$work/check"
"$work/check"
