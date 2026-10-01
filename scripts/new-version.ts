#!/usr/bin/env bun
import { mkdir, mkdtemp, readFile, readdir, rm, writeFile } from "node:fs/promises";
import { appendFileSync, closeSync, mkdirSync, openSync } from "node:fs";
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

function listItems<T>(output: string): T[] {
  const response: { data?: T[]; items?: T[] } = JSON.parse(output);
  const items = response.data ?? response.items;
  if (!Array.isArray(items)) throw new Error("Unexpected App Store Connect list response.");
  return items;
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
      "dry-run": { type: "boolean" }, resume: { type: "boolean" }, verbose: { type: "boolean" }, help: { type: "boolean" },
    },
  });
  if (values.help) {
    console.log('Usage: bun scripts/new-version.ts patch|minor|major [--notes "What changed"] [--since COMMIT] [--dry-run] [--verbose]\n       bun scripts/new-version.ts --resume [--dry-run] [--verbose]');
    return;
  }
  if (positionals.length !== (values.resume ? 0 : 1) || (values.resume && (values.notes || values.since))) {
    throw new Error("Choose a bump or --resume. Run with --help for usage.");
  }
  const logPath = join(process.cwd(), ".asc", "logs", `release-${Date.now()}-${crypto.randomUUID()}.log`);
  mkdirSync(join(process.cwd(), ".asc", "logs"), { recursive: true });
  const run = (command: string[], capture = false, label?: string, allowFailure = false): string => {
    if (label) console.log(`› ${label}…`);
    const log = openSync(logPath, "a", 0o600);
    try {
      appendFileSync(log, `\n$ ${command[0]} ${command[1] ?? ""}\n`);
      const result = Bun.spawnSync(command, {
        env: { ...process.env }, stdin: "ignore",
        stdout: capture ? "pipe" : values.verbose ? "inherit" : log,
        stderr: values.verbose ? "inherit" : log,
      });
      if (capture) appendFileSync(log, result.stdout);
      if (result.exitCode !== 0 && !allowFailure) throw new Error(`${label ?? `${command[0]} ${command[1]}`} failed.\nFull log: ${logPath}`);
      if (label) console.log(`✓ ${label}`);
      return capture ? result.stdout.toString().trimEnd() : "";
    } finally {
      closeSync(log);
    }
  };
  const project = await readFile(projectPath, "utf8");
  const previousVersion = projectValue(project, "MARKETING_VERSION");
  const version = values.resume ? previousVersion : bumpVersion(previousVersion, positionals[0]!);
  const metadataPath = `metadata/version/${version}`;
  const tag = `release/v${version}`;
  if (run(["git", "tag", "--list", tag], true)) throw new Error(`${version} was already submitted.`);
  if (!values.resume && !values["dry-run"] && run(["git", "status", "--porcelain", "--", ".", ":(top,exclude)landing", ":(top,exclude)scripts"], true)) {
    throw new Error("Commit your changes before releasing so the release tag records the built source.");
  }
  const sourceCommit = run(["git", "rev-parse", "HEAD"], true);
  const work = await mkdtemp(join(tmpdir(), "waypoint-release-"));
  let releaseStarted = Boolean(values.resume);
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
        `Write only the English App Store What's New text for Waypoint ${version}. Read git log and git diff from ${commit} to HEAD. Inspect the changed app code when commit messages are vague. Include only verified user-facing iPhone app changes. Omit landing pages, videos, tooling, dependencies, and internal refactors. Do not invent benefits or fixes. If there are no verified user-facing changes, output exactly NO_USER_FACING_CHANGES. Otherwise output a plain-text bullet list, one concise sentence per line. Every line must begin with exactly one category: "- Feature: " for a new capability, "- Fix: " for corrected broken behavior, or "- Improve: " for an enhancement to an existing capability. Describe what changed for the user in concrete everyday language. Combine closely related changes and avoid duplicates. Group rows by Feature, Fix, then Improve, omitting categories with no changes. No section headings, nested bullets, blank lines between rows, version title, preamble, or closing summary. Maximum 4000 characters. Only read local files and git history. Do not edit files, run builds, or use connectors.`], false, "Generating release notes");
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
      if (run(["git", "rev-parse", "HEAD"], true) !== sourceCommit || run(["git", "status", "--porcelain", "--", ".", ":(top,exclude)landing", ":(top,exclude)scripts"], true)) {
        throw new Error("Source changed while generating notes. Commit your changes and start again.");
      }
      const pending = run(["asc", "versions", "list", "--app", appId, "--platform", "IOS", "--version", version, "--output", "json"], true);
      if (listItems<unknown>(pending).length) throw new Error(`${version} already exists in App Store Connect. Inspect it before continuing.`);
      run(["asc", "metadata", "pull", "--app", appId, "--version", previousVersion, "--platform", "IOS", "--dir", work], false, "Loading App Store metadata");
      const locales = await readdir(join(work, "version", previousVersion));
      if (locales.length !== 1 || locales[0] !== "en-US.json") throw new Error("This script currently supports the app's en-US locale only.");
      const metadata: Record<string, unknown> = JSON.parse(await readFile(join(work, "version", previousVersion, "en-US.json"), "utf8"));
      await mkdir(metadataPath, { recursive: true });
      releaseStarted = true;
      await writeFile(`${metadataPath}/en-US.json`, JSON.stringify({ ...metadata, whatsNew: notes }, null, 2) + "\n");
      await writeFile(projectPath, project.replace(/("?MARKETING_VERSION"? = )"?[\d.]+"?;/g, `$1"${version}";`));
      await mkdir(".asc/releases", { recursive: true });
      await writeFile(`.asc/releases/${version}.json`, JSON.stringify({ sourceCommit }));
      console.log(`✓ Updated app and extension versions to ${version}`);
    }
    const release: { sourceCommit: string } = JSON.parse(await readFile(`.asc/releases/${version}.json`, "utf8"));
    const findBuild = async (): Promise<string | undefined> => {
      const buildNumber = projectValue(await readFile(projectPath, "utf8"), "CURRENT_PROJECT_VERSION");
      const builds = listItems<{ id: string; attributes: { processingState: string } }>(run([
        "asc", "builds", "list", "--app", appId, "--platform", "IOS", "--version", version,
        "--build-number", buildNumber, "--processing-state", "all", "--output", "json",
      ], true));
      const build = builds[0];
      if (build && build.attributes.processingState !== "VALID") throw new Error(`Build ${buildNumber} is ${build.attributes.processingState}. Resolve processing before resuming.`);
      return build?.id;
    };
    let buildId = values.resume ? await findBuild() : undefined;
    if (!buildId) {
      if (release.sourceCommit !== sourceCommit) throw new Error("HEAD changed since this release started. Finish the original release before rebuilding.");
      if (values.resume) {
        const changes = run(["git", "status", "--porcelain", "--untracked-files=all", "--", ".", ":(top,exclude)landing", ":(top,exclude)scripts"], true).split("\n").filter(Boolean);
        if (changes.some((change) => ![projectPath, `${metadataPath}/en-US.json`].includes(change.slice(3)))) {
          throw new Error("Source changed since the release started. Restore those changes before rebuilding.");
        }
        const original = run(["git", "show", `${sourceCommit}:${projectPath}`], true);
        const normalize = (text: string) => text.replace(/("?(?:MARKETING_VERSION|CURRENT_PROJECT_VERSION)"? = )"?[\d.]+"?;/g, "$1VERSION;").trimEnd();
        if (normalize(original) !== normalize(project)) throw new Error("Project settings changed since the release started.");
      }
      run(["sh", "scripts/testflight.sh", notes], false, "Building and uploading to TestFlight");
      buildId = await findBuild();
    }
    if (!buildId) throw new Error("Uploaded build was not found.");
    console.log(`✓ Using ${version} build ${projectValue(await readFile(projectPath, "utf8"), "CURRENT_PROJECT_VERSION")}`);
    const versions = listItems<{ attributes: { appStoreState: string } }>(run([
      "asc", "versions", "list", "--app", appId, "--platform", "IOS", "--version", version, "--output", "json",
    ], true));
    const state = versions[0]?.attributes.appStoreState;
    if (state && !["PREPARE_FOR_SUBMISSION", "READY_FOR_REVIEW", "DEVELOPER_REJECTED", "REJECTED", "METADATA_REJECTED", "INVALID_BINARY"].includes(state)) {
      throw new Error(`Version ${version} is ${state}. Inspect its existing submission before retrying.`);
    }
    const stage = ["asc", "release", "stage", "--app", appId, "--version", version, "--build-id", buildId, "--checkpoint-file", `.asc/releases/${version}-stage.json`, "--metadata-dir", "metadata"];
    const stagePlan: {
      status: string; failedStep?: string; error?: string;
      steps?: { name: string; details?: { report?: { checks?: { severity: string; id: string }[] } } }[];
    } = JSON.parse(run([...stage, "--dry-run"], true, undefined, true));
    if (stagePlan.status === "error") {
      const blockers = stagePlan.steps?.find((step) => step.name === "validate_readiness")?.details?.report?.checks?.filter((check) => check.severity === "error") ?? [];
      if (stagePlan.failedStep !== "validate_readiness" || !blockers.length || blockers.some((check) => check.id !== "build.required.missing")) {
        throw new Error(`Staging plan failed: ${stagePlan.error ?? "unexpected failure"}`);
      }
    } else if (stagePlan.status !== "dry-run") {
      throw new Error("Staging did not return a valid dry-run plan.");
    }
    run([...stage, "--confirm"], false, "Staging App Store version");
    run(["asc", "validate", "--app", appId, "--version", version, "--platform", "IOS"], false, "App Store validation");
    const review = ["asc", "review", "submit", "--app", appId, "--version", version, "--build-id", buildId];
    run([...review, "--dry-run"]);
    run([...review, "--confirm"], false, "Submitting for review");
    run(["git", "tag", tag, release.sourceCommit]);
    console.log(`Submitted ${version} for App Store review. Commit the updated project and metadata, then push ${tag}.`);
    console.log(`Full log: ${logPath}`);
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    const retry = releaseStarted
      ? "After resolving the issue, retry with bun scripts/new-version.ts --resume."
      : "Release has not started. After resolving the issue, rerun your original command.";
    throw new Error(`${message}\n${message.includes(logPath) ? "" : `Full log: ${logPath}\n`}${retry}`);
  } finally {
    await rm(work, { recursive: true, force: true });
  }
}

if (import.meta.main) {
  process.chdir(join(import.meta.dir, ".."));
  main(Bun.argv.slice(2)).catch((error: unknown) => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  });
}
