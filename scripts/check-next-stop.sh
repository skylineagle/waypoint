#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
swiftc Shared/NextStop.swift Checks/NextStop/main.swift -o "$work/check"
"$work/check"
