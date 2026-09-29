#!/bin/sh
set -e
cd "$(dirname "$0")/.."
swiftc -O -o /tmp/read-receipt TrekCompanion/ReceiptText.swift Checks/ReceiptReader/main.swift
/tmp/read-receipt "$@"
