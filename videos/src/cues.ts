const BEAT = 0.5;

export const beat = (count: number) => count * BEAT;
export const bar = (count: number) => count * BEAT * 4;

export const scenes = {
  opening: { start: 0, end: bar(2) },
  onboarding: { start: bar(2), end: bar(5) },
  today: { start: bar(5), end: bar(7) },
  live: { start: bar(7), end: bar(9) },
  widgets: { start: bar(9), end: bar(10.5) },
  costs: { start: bar(10.5), end: bar(12) },
  dayNight: { start: bar(12), end: bar(14) },
  finale: { start: bar(14), end: bar(16) },
};

export type SceneWindow = { start: number; end: number };

export const cuts = Object.values(scenes)
  .map((scene) => scene.start)
  .filter((start) => start > 0);

export const DROP = bar(13);
