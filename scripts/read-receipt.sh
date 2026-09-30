#!/bin/sh
set -e
cd "$(dirname "$0")/.."
swiftc -O -o /tmp/read-receipt TrekCompanion/ReceiptRows.swift TrekCompanion/ReceiptRules.swift TrekCompanion/ReceiptModel.swift TrekCompanion/ReceiptParser.swift Checks/ReceiptReader/main.swift
/tmp/read-receipt "$@"
