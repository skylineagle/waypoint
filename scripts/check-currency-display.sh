#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
swiftc -parse-as-library TrekCompanion/TrekModels.swift TrekCompanion/CurrencyConverter.swift Checks/CurrencyDisplay/main.swift -o "$work/check"
"$work/check"
