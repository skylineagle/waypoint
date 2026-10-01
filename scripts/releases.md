Run from the repository root. Requires Bun, authenticated `asc`, Xcode signing, and authenticated `codex` for automatic notes.

By default, the terminal shows step progress, the release notes once, and the result. Codex's session output, build output, and App Store command responses go to a private log under `.asc/logs/`. Failed commands show the step and log path, with retry advice based on whether the release started. Add `--verbose` to stream command output directly instead.

```sh
bun scripts/new-version.ts patch
bun scripts/new-version.ts minor
bun scripts/new-version.ts major
```

The command bumps the app, widget, and share extension versions, generates English What's New notes from the changes since the previous release tag, runs the existing TestFlight build/upload script, carries forward the previous version's current App Store metadata, and submits the exact uploaded build for App Store review after validation. Apple still decides whether to approve it.

Commit your app changes before running a release. Changes under `landing/` and `scripts/` are ignored by the initial check and resume checks, including staged and untracked files. The first automatic release needs the commit used for the previous App Store release because there are no release tags yet:

```sh
bun scripts/new-version.ts patch --since <previous-release-commit> --dry-run
bun scripts/new-version.ts patch --since <previous-release-commit>
```

Dry runs print generated notes without changing the project or contacting Apple. They inspect committed changes. Later releases find the baseline automatically using `release/v<previous-version>`.

To provide your own message instead:

```sh
bun scripts/new-version.ts patch --notes "Booking reminders and improvements to your daily itinerary."
```

If a build, upload, metadata stage, or validation fails after the release starts, fix the reported issue and retry without another bump:

```sh
bun scripts/new-version.ts --resume
```

Resume preserves the version and notes and reuses the matching uploaded build. Local source changes do not block staging an already uploaded build. If upload never completed, it rebuilds with a fresh build number and requires the original HEAD and unchanged app source. Processing failures and versions already under review stop the command for inspection.

After successful submission, commit the updated Xcode project and `metadata/version/<version>/en-US.json`, and push the created release tag. Existing `scripts/testflight.sh` usage continues to work independently.

```sh
bun test scripts/new-version.test.ts
```
