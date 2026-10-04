import { readFile, writeFile } from "node:fs/promises";

const landing = new URL("../", import.meta.url);

function escapeHtml(text: string): string {
  return text.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");
}

function inline(text: string): string {
  return escapeHtml(text)
    .replace(/\[([^\]]+)\]\((https:\/\/[^)]+)\)/g, '<a href="$2">$1</a>')
    .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
    .replace(/`([^`]+)`/g, "<code>$1</code>");
}

function slug(text: string): string {
  return text.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

type Section = { title: string; id: string; content: string };

function page(title: string, metadata: string, introduction: string, sections: Section[], source: string): string {
  const current = title === "Privacy policy" ? "privacy" : "license";
  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
    <meta name="color-scheme" content="dark" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="${escapeHtml(title)} for Waypoint, the iPhone app for your TREK server." />
    <title>${title} · Waypoint</title>
    <link rel="icon" href="./media/apple-touch-icon.png" />
    <link rel="stylesheet" href="./src/styles.css" />
    <link rel="stylesheet" href="./src/legal.css" />
  </head>
  <body>
    <a class="skip-link" href="#document">Skip to document</a>
    <nav class="localnav" aria-label="Waypoint">
      <div class="localnav-inner">
        <a class="localnav-title" href="./">Waypoint</a>
        <div class="legal-nav-links"><a href="./">Back to home <span aria-hidden="true">↗</span></a><a href="https://github.com/skylineagle/waypoint">GitHub <span aria-hidden="true">↗</span></a></div>
      </div>
    </nav>
    <main class="legal-layout">
      <aside class="legal-index">
        <nav aria-label="On this page">
          <p>On this page</p>
          ${sections.map(section => `<a href="#${section.id}">${escapeHtml(section.title)}</a>`).join("\n          ")}
        </nav>
      </aside>
      <article class="legal-document" id="document">
        <header>
          <p class="legal-eyebrow">Waypoint</p>
          <h1>${title}</h1>
          <p class="legal-metadata">${escapeHtml(metadata)}</p>
          <nav class="legal-tabs" aria-label="Legal documents">
            <a href="./privacy.html" ${current === "privacy" ? 'aria-current="page"' : ""}>Privacy policy</a>
            <a href="./license.html" ${current === "license" ? 'aria-current="page"' : ""}>License</a>
          </nav>
        </header>
        <div class="legal-body">${introduction}
          ${sections.map(section => `<section aria-labelledby="${section.id}"><h2 id="${section.id}">${escapeHtml(section.title)}</h2>${section.content}</section>`).join("\n          ")}
        </div>
        <p class="legal-source">From the Waypoint repository. <a href="https://github.com/skylineagle/waypoint/blob/main/${source}">View on GitHub <span aria-hidden="true">↗</span></a></p>
      </article>
    </main>
    <footer class="legal-footer"><p>Copyright © 2026 Ofek Nesher.</p><nav aria-label="Footer"><a href="./privacy.html">Privacy policy</a><a href="./license.html">License</a><a href="https://github.com/skylineagle/waypoint/issues">Support</a></nav></footer>
  </body>
</html>
`;
}

function paragraphs(text: string): string {
  return text.trim().split(/\n\n+/).map(block => block.startsWith("- ")
    ? `<ul>${block.split("\n").map(line => `<li>${inline(line.slice(2))}</li>`).join("")}</ul>`
    : `<p>${inline(block).replaceAll("\n", "<br />")}</p>`).join("\n");
}

const privacy = await readFile(new URL("../PRIVACY.md", landing), "utf8");
const [privacyIntroduction, ...privacyBlocks] = privacy.split(/^## /m);
const privacySections = privacyBlocks.map(block => {
  const newline = block.indexOf("\n");
  const title = block.slice(0, newline);
  return { title, id: slug(title), content: paragraphs(block.slice(newline + 1)) };
});
const metadata = privacyIntroduction.match(/^Last updated .+$/m)?.[0] ?? "";
const introduction = privacyIntroduction.replace(/^# .+\n+/m, "").replace(/^\*\*Waypoint\*\*\nLast updated .+\n+/m, "");
await writeFile(new URL("privacy.html", landing), page("Privacy policy", metadata, paragraphs(introduction), privacySections, "PRIVACY.md"));

const license = await readFile(new URL("../LICENSE", landing), "utf8");
const headings = [...license.matchAll(/^(?: +(?:Preamble|TERMS AND CONDITIONS|How to Apply These Terms to Your New Programs)| {2}\d+\. [^\n]+)\r?$/gm)];
const licenseSections = headings.map((heading, index) => {
  const title = heading[0].trim();
  const end = headings[index + 1]?.index ?? license.length;
  return { title, id: slug(title), content: `<pre>${escapeHtml(license.slice(heading.index + heading[0].length, end))}</pre>` };
});
const licenseIntroduction = `<pre>${escapeHtml(license.slice(0, headings[0]?.index ?? license.length))}</pre>`;
await writeFile(new URL("license.html", landing), page("License", "GNU Affero General Public License · Version 3, 19 November 2007", licenseIntroduction, licenseSections, "LICENSE"));
