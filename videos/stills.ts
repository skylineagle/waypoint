import { bundle } from "@remotion/bundler";
import { renderStill, selectComposition } from "@remotion/renderer";
import path from "node:path";

const browserExecutable = "/Users/eagle/Library/Caches/ms-playwright/chromium_headless_shell-1243/chrome-headless-shell-mac-arm64/chrome-headless-shell";
const [folder, ...seconds] = process.argv.slice(2);
const serveUrl = await bundle({ entryPoint: path.resolve("src/index.ts") });
const composition = await selectComposition({ serveUrl, id: "Promo", browserExecutable });
for (const second of seconds.map(Number)) {
  const frame = Math.min(composition.durationInFrames - 1, Math.round(second * composition.fps));
  await renderStill({ composition, serveUrl, frame, output: `${folder}/t${second.toFixed(2)}.png`, browserExecutable, scale: 0.5 });
}
