#!/usr/bin/env bun
import { mkdir, mkdtemp, readFile, readdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { parseArgs } from "node:util";

const appId = "6817039570";
const projectPath = "TrekCompanion.xcodeproj/project.pbxproj";

export function bumpVersion(version: string, bump: string): string {
  if (!/^\d+\.\d+(?:\.\d+)?$/.test(version)) throw new Error(`Invalid version: ${version}`);
  const parts = version.split(".").map(Number);
  parts[2] ??= 0;
  const index = ["major", "minor", "patch"].indexOf(bump);
  if (index < 0) throw new Error("Choose patch, minor, or major.");
  if (parts.some((part) => !Number.isSafeInteger(part)) || !Number.isSafeInteger(parts[index]! + 1)) {
    throw new Error("Version number is too large.");
  }
  parts[index]!++;
  return parts.map((part, position) => position > index ? 0 : part).join(".");
}

function run(command: string[], capture = false): string {
  const result = Bun.spawnSync(command, { env: { ...process.env }, stdin: "ignore", stdout: capture ? "pipe" : "inherit", stderr: "inherit" });
  if (result.exitCode !== 0) throw new Error(`${command[0]} ${command[1]} failed.`);
  return capture ? result.stdout.toString().trimEnd() : "";
}

function projectValue(project: string, key: string): string {
  const values = [...project.matchAll(new RegExp(`"?${key}"? = "?([\\d.]+)"?;`, "g"))].map((match) => match[1]!);
  if (!values.length || new Set(values).size !== 1) throw new Error(`${key} must match across all targets.`);
  return values[0]!;
}

export async function main(args: string[]): Promise<void> {
  const { values, positionals } = parseArgs({
    args, allowPositionals: true,
    options: {
      notes: { type: "string" }, since: { type: "string" },
      "dry-run": { type: "boolean" }, resume: { type: "boolean" }, help: { type: "boolean" },
    },
  });
  if (values.help) {
    console.log('Usage: bun scripts/new-version.ts patch|minor|major [--notes "What changed"] [--since COMMIT] [--dry-run]\n       bun scripts/new-version.ts --resume [--dry-run]');
    return;
  }
  if (positionals.length !== (values.resume ? 0 : 1) || (values.resume && (values.notes || values.since))) {
    throw new Error("Choose a bump or --resume. Run with --help for usage.");
  }
  const project = await readFile(projectPath, "utf8");
  const previousVersion = projectValue(project, "MARKETING_VERSION");
  const version = values.resume ? previousVersion : bumpVersion(previousVersion, positionals[0]!);
  const metadataPath = `metadata/version/${version}`;
  const tag = `release/v${version}`;
  if (run(["git", "tag", "--list", tag], true)) throw new Error(`${version} was already submitted.`);
  if (!values.resume && !values["dry-run"] && run(["git", "status", "--porcelain"], true)) {
    throw new Error("Commit your changes before releasing so the release tag records the built source.");
  }
  const sourceCommit = run(["git", "rev-parse", "HEAD"], true);
  const work = await mkdtemp(join(tmpdir(), "waypoint-release-"));
  try {
    let notes: string;
    if (values.resume) {
      const metadata: { whatsNew?: string } = JSON.parse(await readFile(`${metadataPath}/en-US.json`, "utf8"));
      notes = metadata.whatsNew ?? "";
    } else if (values.notes !== undefined) {
      notes = values.notes;
    } else {
      const baseline = values.since ?? run(["git", "tag", "--list", `release/v${previousVersion}`], true);
      if (!baseline) throw new Error("First release: provide --since <previous-release-commit> or --notes \"What changed\".");
      const commit = run(["git", "rev-parse", "--verify", `${baseline}^{commit}`], true);
      run(["git", "merge-base", "--is-ancestor", commit, "HEAD"]);
      const outputPath = join(work, "notes.txt");
      run(["codex", "exec", "--sandbox", "read-only", "--ephemeral", "--output-last-message", outputPath,
        `Write only the English App Store What's New text for Waypoint ${version}. Read git log and git diff from ${commit} to HEAD. Inspect the changed app code when commit messages are vague. Include only verified user-facing iPhone app changes. Omit landing pages, videos, tooling, dependencies, and internal refactors. Do not invent benefits or fixes. If there are no verified user-facing changes, output exactly NO_USER_FACING_CHANGES. Use plain concise sentences, no Markdown headings, no version title, no preamble. Maximum 4000 characters. Only read local files and git history. Do not edit files, run builds, or use connectors.`]);
      notes = await readFile(outputPath, "utf8");
    }
    notes = notes.trim();
    if (notes === "NO_USER_FACING_CHANGES") throw new Error("No user-facing changes found. Check --since or provide --notes.");
    if (!notes || [...notes].length > 4000) throw new Error("What's New must contain 1–4000 characters.");
    console.log(`Version ${version}\n\n${notes}\n`);
    if (values["dry-run"]) {
      console.log("Dry run: would bump all targets, build/upload through testflight.sh, stage metadata, validate, and submit for review.");
      return;
    }
    if (!values.resume) {
      if (run(["git", "rev-parse", "HEAD"], true) !== sourceCommit || run(["git", "status", "--porcelain"], true)) {
        throw new Error("Source changed while generating notes. Commit your changes and start again.");
      }
      const pending = run(["asc", "versions", "list", "--app", appId, "--platform", "IOS", "--version", version, "--output", "json"], true);
      const existing: { items: unknown[] } = JSON.parse(pending);
      if (existing.items.length) throw new Error(`${version} already exists in App Store Connect. Inspect it before continuing.`);
      run(["asc", "metadata", "pull", "--app", appId, "--version", previousVersion, "--platform", "IOS", "--dir", work]);
      const locales = await readdir(join(work, "version", previousVersion));
      if (locales.length !== 1 || locales[0] !== "en-US.json") throw new Error("This script currently supports the app's en-US locale only.");
      const metadata: Record<string, unknown> = JSON.parse(await readFile(join(work, "version", previousVersion, "en-US.json"), "utf8"));
      await mkdir(metadataPath, { recursive: true });
      await writeFile(`${metadataPath}/en-US.json`, JSON.stringify({ ...metadata, whatsNew: notes }, null, 2) + "\n");
      await writeFile(projectPath, project.replace(/("?MARKETING_VERSION"? = )"?[\d.]+"?;/g, `$1"${version}";`));
      await mkdir(".asc/releases", { recursive: true });
      await writeFile(`.asc/releases/${version}.json`, JSON.stringify({ sourceCommit }));
    }
    const release: { sourceCommit: string } = JSON.parse(await readFile(`.asc/releases/${version}.json`, "utf8"));
    if (release.sourceCommit !== sourceCommit) throw new Error("HEAD changed since this release started. Finish the original release before rebuilding.");
    if (values.resume) {
      const changes = run(["git", "status", "--porcelain", "--untracked-files=all"], true).split("\n").filter(Boolean);
      if (changes.some((change) => ![projectPath, `${metadataPath}/en-US.json`].includes(change.slice(3)))) {
        throw new Error("Source changed since the release started. Restore those changes before resuming.");
      }
      const original = run(["git", "show", `${sourceCommit}:${projectPath}`], true);
      const normalize = (text: string) => text.replace(/("?(?:MARKETING_VERSION|CURRENT_PROJECT_VERSION)"? = )"?[\d.]+"?;/g, "$1VERSION;").trimEnd();
      if (normalize(original) !== normalize(project)) throw new Error("Project settings changed since the release started.");
    }
    const findBuild = async (): Promise<string | undefined> => {
      const buildNumber = projectValue(await readFile(projectPath, "utf8"), "CURRENT_PROJECT_VERSION");
      const response: { items: { id: string; attributes: { processingState: string } }[] } = JSON.parse(run([
        "asc", "builds", "list", "--app", appId, "--platform", "IOS", "--version", version,
        "--build-number", buildNumber, "--processing-state", "all", "--output", "json",
      ], true));
      const build = response.items[0];
      if (build && build.attributes.processingState !== "VALID") throw new Error(`Build ${buildNumber} is ${build.attributes.processingState}. Resolve processing before resuming.`);
      return build?.id;
    };
    let buildId = values.resume ? await findBuild() : undefined;
    if (!buildId) {
      run(["sh", "scripts/testflight.sh", notes]);
      buildId = await findBuild();
    }
    if (!buildId) throw new Error("Uploaded build was not found.");
    const versions: { items: { attributes: { appStoreState: string } }[] } = JSON.parse(run([
      "asc", "versions", "list", "--app", appId, "--platform", "IOS", "--version", version, "--output", "json",
    ], true));
    const state = versions.items[0]?.attributes.appStoreState;
    if (state && !["PREPARE_FOR_SUBMISSION", "READY_FOR_REVIEW", "DEVELOPER_REJECTED", "REJECTED", "METADATA_REJECTED", "INVALID_BINARY"].includes(state)) {
      throw new Error(`Version ${version} is ${state}. Inspect its existing submission before retrying.`);
    }
    const stage = ["asc", "release", "stage", "--app", appId, "--version", version, "--build-id", buildId, "--metadata-dir", metadataPath];
    run([...stage, "--dry-run"]);
    run([...stage, "--confirm"]);
    run(["asc", "validate", "--app", appId, "--version", version, "--platform", "IOS"]);
    const review = ["asc", "review", "submit", "--app", appId, "--version", version, "--build-id", buildId];
    run([...review, "--dry-run"]);
    run([...review, "--confirm"]);
    run(["git", "tag", tag, release.sourceCommit]);
    console.log(`Submitted ${version} for App Store review. Commit the updated project and metadata, then push ${tag}.`);
  } finally {
    await rm(work, { recursive: true, force: true });
  }
}

if (import.meta.main) {
  process.chdir(join(import.meta.dir, ".."));
  main(Bun.argv.slice(2)).catch((error: unknown) => {
    console.error(error instanceof Error ? error.message : String(error));
    console.error("After a release has started, retry with bun scripts/new-version.ts --resume.");
    process.exitCode = 1;
  });
}
