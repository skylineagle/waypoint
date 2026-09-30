#!/bin/sh
set -e
cd "$(dirname "$0")/.."
swiftc -O -o /tmp/receipt-lab TrekCompanion/ReceiptRows.swift TrekCompanion/ReceiptRules.swift TrekCompanion/ReceiptModel.swift TrekCompanion/ReceiptParser.swift Checks/ReceiptLab/main.swift
/tmp/receipt-lab "$@"
