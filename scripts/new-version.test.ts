import { afterEach, beforeEach, expect, test } from "bun:test";
import { chmod, mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { bumpVersion, main } from "./new-version";

const originalDirectory = process.cwd();
const originalPath = process.env.PATH;
let work: string;

function git(...args: string[]): string {
  const result = Bun.spawnSync(["git", ...args], { stdout: "pipe", stderr: "pipe" });
  if (result.exitCode) throw new Error(result.stderr.toString());
  return result.stdout.toString().trim();
}

beforeEach(async () => {
  work = await mkdtemp(join(tmpdir(), "release-check-"));
  const repository = join(work, "repo");
  await mkdir(join(work, "bin"));
  await mkdir(join(repository, "scripts"), { recursive: true });
  await mkdir(join(repository, "TrekCompanion.xcodeproj"));
  await writeFile(join(repository, ".gitignore"), ".asc/\n");
  await writeFile(join(repository, "TrekCompanion.xcodeproj/project.pbxproj"),
    'MARKETING_VERSION = "1.0";\n"MARKETING_VERSION" = "1.0";\nCURRENT_PROJECT_VERSION = 10;\n');
  await writeFile(join(repository, "scripts/testflight.sh"),
    'set -e\nmkdir -p .asc\necho upload >> .asc/commands\nsed -i "" "s/CURRENT_PROJECT_VERSION = 10/CURRENT_PROJECT_VERSION = 11/" TrekCompanion.xcodeproj/project.pbxproj\ntouch .asc/uploaded\n');
  await writeFile(join(work, "bin/asc"), `#!/usr/bin/env bun
const args = Bun.argv.slice(2);
const option = (name: string) => args[args.indexOf(name) + 1]!;
await Bun.write(".asc/commands", (await Bun.file(".asc/commands").text().catch(() => "")) + args.join(" ") + "\\n");
if (args[0] === "versions") console.log(JSON.stringify({ items: process.env.RELEASE_STATE ? [{ attributes: { appStoreState: process.env.RELEASE_STATE } }] : [] }));
if (args[0] === "metadata") await Bun.write(option("--dir") + "/version/" + option("--version") + "/en-US.json", JSON.stringify({ description: "Existing description", whatsNew: "Old notes" }));
if (args[0] === "builds") console.log(JSON.stringify({ items: await Bun.file(".asc/uploaded").exists() ? [{ id: "exact-build", attributes: { processingState: "VALID" } }] : [] }));
if (args[0] === "validate" && process.env.FAIL_VALIDATION) process.exit(1);
`);
  await writeFile(join(work, "bin/codex"), `#!/usr/bin/env bun
const args = Bun.argv.slice(2);
await Bun.write(args[args.indexOf("--output-last-message") + 1]!, "Your upcoming bookings now have reminders.");
`);
  await chmod(join(work, "bin/asc"), 0o755);
  await chmod(join(work, "bin/codex"), 0o755);
  process.env.PATH = `${work}/bin:${originalPath}`;
  process.chdir(repository);
  git("init", "-q");
  git("add", ".");
  git("-c", "user.name=Release check", "-c", "user.email=check@example.com", "commit", "-qm", "Initial source");
});

afterEach(async () => {
  process.chdir(originalDirectory);
  process.env.PATH = originalPath;
  delete process.env.FAIL_VALIDATION;
  delete process.env.RELEASE_STATE;
  await rm(work, { recursive: true, force: true });
});

test("bumps two- and three-part versions and rejects invalid input", () => {
  expect(bumpVersion("1.0", "patch")).toBe("1.0.1");
  expect(bumpVersion("1.2.9", "minor")).toBe("1.3.0");
  expect(bumpVersion("1.2.9", "major")).toBe("2.0.0");
  expect(() => bumpVersion("1.2-beta", "patch")).toThrow();
  expect(() => bumpVersion("1.2", "other")).toThrow();
});

test("automatic notes need a baseline and dry run leaves the checkout unchanged", async () => {
  await expect(main(["patch", "--dry-run"])).rejects.toThrow("First release");
  await main(["patch", "--since", "HEAD", "--dry-run"]);
  expect(git("status", "--porcelain")).toBe("");
  expect(await Bun.file(".asc/uploaded").exists()).toBe(false);
});

test("validation blocks submission; resume reuses the exact build and notes", async () => {
  process.env.FAIL_VALIDATION = "1";
  await expect(main(["minor", "--since", "HEAD"])).rejects.toThrow("validate failed");
  const project = await readFile("TrekCompanion.xcodeproj/project.pbxproj", "utf8");
  expect(project.match(/1\.1\.0/g)?.length).toBe(2);
  const notes = JSON.parse(await readFile("metadata/version/1.1.0/en-US.json", "utf8")) as { description: string; whatsNew: string };
  expect(notes).toEqual({ description: "Existing description", whatsNew: "Your upcoming bookings now have reminders." });
  expect(await readFile(".asc/commands", "utf8")).not.toContain("review submit");
  delete process.env.FAIL_VALIDATION;
  await main(["--resume"]);
  const commands = await readFile(".asc/commands", "utf8");
  expect(commands.match(/^upload$/gm)?.length).toBe(1);
  expect(commands).toContain("--build-number 11");
  expect(commands).toContain("review submit --app 6817039570 --version 1.1.0 --build-id exact-build --dry-run");
  expect(commands).toContain("review submit --app 6817039570 --version 1.1.0 --build-id exact-build --confirm");
  expect(git("tag", "--list")).toBe("release/v1.1.0");
  await expect(main(["--resume"])).rejects.toThrow("already submitted");
});

test("resume rejects source changes and an existing review submission", async () => {
  process.env.FAIL_VALIDATION = "1";
  await expect(main(["patch", "--notes", "Booking reminders."])).rejects.toThrow();
  await writeFile("changed.swift", "changed source");
  await expect(main(["--resume"])).rejects.toThrow("Source changed");
  await rm("changed.swift");
  delete process.env.FAIL_VALIDATION;
  process.env.RELEASE_STATE = "WAITING_FOR_REVIEW";
  await expect(main(["--resume"])).rejects.toThrow("existing submission");
  expect(await readFile(".asc/commands", "utf8")).not.toContain("review submit");
});
