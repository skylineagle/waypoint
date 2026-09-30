export const BPM = 100;
export const BEAT = 60 / BPM;
export const BAR = BEAT * 4;

export const WIDTH = 1920;
export const HEIGHT = 1080;
export const FPS = 60;

export const at = (bar: number, beat = 0) => bar * BAR + beat * BEAT;

export type SceneWindow = { start: number; end: number };

const span = (from: number, to: number): SceneWindow => ({ start: at(from), end: at(to) });

export type Chapter = {
  window: SceneWindow;
  clip: string;
  trimStart: number;
  trimEnd: number;
  time: string;
  title: string;
  line: string;
};

export const opening = span(0, 2);

export const chapters: Chapter[] = [
  { window: span(2, 6), clip: "plan", trimStart: 2.0, trimEnd: 10.5, time: "08:30", title: "Plan the day.", line: "Today's stops, the map, and a peek at tomorrow." },
  { window: span(6, 10), clip: "arrive", trimStart: 0, trimEnd: 10.73, time: "10:05", title: "Just arrive.", line: "Waypoint notices you're there and moves on to the next stop." },
  { window: span(10, 13), clip: "convert", trimStart: 5.6, trimEnd: 12.7, time: "12:40", title: "What's that back home?", line: "Convert prices right from your Home Screen." },
  { window: span(13, 18), clip: "receipt", trimStart: 0, trimEnd: 11.47, time: "13:15", title: "Lunch, logged.", line: "Pick the receipt. Amount, place and category fill in." },
  { window: span(18, 22), clip: "journey", trimStart: 0, trimEnd: 9.23, time: "19:30", title: "Share the day.", line: "Photos land in your TREK Journey, sorted by stop." },
];

export const finale = span(22, 25);

export const BARS = 25;
export const SECONDS = at(BARS);
