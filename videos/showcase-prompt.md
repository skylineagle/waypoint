# Waypoint showcase (flat, 16:9)

Waypoint is the iPhone companion for a self-hosted TREK server: today's plan, Live Activity, widgets, receipt scanning and photo journeys.
This film plays on X, YouTube and the landing page. It reads with the sound off, because every scene carries its own caption.

- **Format:** 1920×1080 at 60 fps, dark (TREK night), 19 bars at 100 BPM (a bar is 2.4 s), 45.6 s in total.
- **Look:** straight-on phones with no tilt or depth. Scenes push right to left. Callouts magnify the app's real UI in place.
- **Screens:** real simulator captures from the Japan trip in `public/raw/` (the `*-japan`, `widget-*`, `receipt-*`, `share-sheet` and `journey-share` files).
- **Music:** `audio/compose_showcase.py` writes `public/audio/showcase.wav`. It is synthesized, so there are no licensing issues.

## Beat sheet (`src/showcase/cues.ts`)

| Bars | Time | Scene | What moves |
|---|---|---|---|
| 0–2 | 0.0–4.8 s | Opening | The icon springs in and the wordmark builds letter by letter. The tagline lands on bar 1. |
| 2–5 | 4.8–12.0 s | Today | The phone pushes in on the right. The map callout lands on 2.2 and Up Next on 3.2. |
| 5–7 | 12.0–16.8 s | Live Activity | The Lock Screen is on the left. The activity card magnifies on 5.2. |
| 7–9 | 16.8–21.6 s | Widgets | The converter widget types ¥7, then ¥79 on 8.0, then ¥795 on 8.1. The photo widget appears on 8.2. |
| 9–12 | 21.6–28.8 s | Receipt scan | The Costs total shows on 9.1. **Drop on bar 10:** the receipt fills in, then the amount (10.1), the receipt (10.2) and the Food category (10.3) magnify. |
| 12–15 | 28.8–36.0 s | Journey | The share sheet shows the Waypoint icon (12.2), then photos group by stop on 13.1, 13.2 and 13.3. |
| 15–17 | 36.0–40.8 s | Lineup | "One app for the whole trip." Three phones rise on the beats. |
| 17–19 | 40.8–45.6 s | Finale | Icon, wordmark, tagline, then "Works with your self-hosted TREK." |

## Render

```bash
bunx remotion render src/index.ts Showcase out/showcase/vN/raw.mp4 --props='{"withAudio":true}' --crf=16 --concurrency=5 --timeout=120000
bunx remotion still src/index.ts Hero out/social/waypoint-hero-x.png
COMP=Showcase bun stills.ts out/review/sN 7.2 26 33.5
```

Then run ffmpeg `loudnorm` to -14 LUFS.
