# Landing site

Run `bun run dev` for the home, privacy policy, and license pages. Run `bun run build` to produce the static site in `dist`.

The legal pages use the repository's `PRIVACY.md` and `LICENSE`. After updating either document, run `bun run sync:legal` from this directory and commit the generated HTML pages with the document changes. Generated pages are checked in so the landing-only Docker build can include them.
