#!/bin/sh
set -e
udid=${1:-C3B2F576-B8CD-4D35-97C4-4609DEC7FBF5}
xcrun --sdk iphonesimulator swiftc -target arm64-apple-ios26.0-simulator -parse-as-library \
  TrekCompanion/TrekModels.swift TrekCompanion/CurrencyConverter.swift TrekCompanion/CostCategory.swift TrekCompanion/TrekTheme.swift \
  Checks/CurrencyDisplay/main.swift -o /tmp/currency-check
xcrun simctl spawn "$udid" /tmp/currency-check
