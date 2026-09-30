# Privacy policy

**Waypoint**
Last updated 30 September 2026

Waypoint is an iPhone app for a TREK server you choose. Ofek Nesher makes the app. He does not run your server, and he cannot see your account, your trips, your expenses, or your location.

## What stays on your iPhone

- The server address, email, password, and sign-in token. These are stored in the iOS Keychain on this device.
- A copy of today's plan, so widgets and the Live Activity can show the next stop. That copy stays in an App Group on this device.
- Your location, used on the device to notice when you have stayed at a stop and mark it done.
- Photos you share to a Journey are copied into the app's shared storage until TREK confirms the upload or you cancel it. Pending copies remain when you sign out, so you can finish sending after signing in again. The share extension can read the active trip and sign-in token, but not your saved password.

Signing out deletes the Keychain entry from this iPhone.

## What leaves your iPhone

Requests go to the TREK server whose address you typed. That includes signing in, loading the trip, and saving expenses. When the app asks that server for the weather at a stop, the request includes that stop's coordinates.

Sharing photos sends them to the Journey you choose on that server. Photo metadata, including capture time and embedded location, is preserved. Waypoint receives only the photos you select in the system share sheet.

Currency conversion asks `api.frankfurter.dev` for a rate. The request sends a currency code. It does not send your name, email, server address, or location.

Opening directions hands the place to Apple Maps, Google Maps, or Waze, whichever you picked in Settings. Those apps have their own privacy policies.

## Location

Waypoint asks to use your location while the app is open, and to keep using it when the app is closed, so a stop can be marked done after you spend time there. You can refuse, or turn it off later in iOS Settings. The rest of the app still works.

Location from this feature is not sent to the person who makes Waypoint.

## What this app does not do

- No account with the developer
- No analytics, advertising, or tracking
- No sale of data
- No access, by the developer, to the TREK server you use

## Children

Waypoint is not directed at children under 13.

## Changes

This file in the [waypoint repository](https://github.com/skylineagle/waypoint) is the current policy. The date at the top changes when the policy changes.

## Contact

Open an issue: [github.com/skylineagle/waypoint/issues](https://github.com/skylineagle/waypoint/issues)
