#!/bin/sh
# Usage: scripts/testflight.sh ["What to test notes"]
set -e
cd "$(dirname "$0")/.."

APP_ID=6817039570
GROUP=f05279a9-0456-4b97-8873-098cae8061ca
ARCHIVE=.asc/artifacts/TrekCompanion.xcarchive
IPA=.asc/artifacts/TrekCompanion.ipa
NOTES=${1:-"$(git log -1 --pretty=%s)"}

BUILD=$(asc builds next-build-number --app "$APP_ID" --platform IOS --output json | plutil -extract nextBuildNumber raw -o - -)
case "$BUILD" in
  ''|*[!0-9]*|0) echo "Could not resolve a valid build number." >&2; exit 1 ;;
esac
echo "› Build number $BUILD (app, widgets and share extension)"
sed -i '' -E "s/(\"?CURRENT_PROJECT_VERSION\"? = )[0-9]+;/\1$BUILD;/" TrekCompanion.xcodeproj/project.pbxproj

echo "› Archiving"
rm -rf "$ARCHIVE" "$IPA"
asc xcode archive \
  --project TrekCompanion.xcodeproj \
  --scheme TrekCompanion \
  --configuration Release \
  --clean \
  --archive-path "$ARCHIVE" \
  --xcodebuild-flag=-destination \
  --xcodebuild-flag=generic/platform=iOS \
  --xcodebuild-flag=-allowProvisioningUpdates

echo "› Exporting"
asc xcode export \
  --archive-path "$ARCHIVE" \
  --ipa-path "$IPA" \
  --xcodebuild-flag=-allowProvisioningUpdates

echo "› Uploading to TestFlight and adding to the internal group"
asc publish testflight \
  --app "$APP_ID" \
  --ipa "$IPA" \
  --group "$GROUP" \
  --test-notes "$NOTES" \
  --locale en-US \
  --wait

echo "✓ Done. It shows up in TestFlight on your phone in a few minutes."
