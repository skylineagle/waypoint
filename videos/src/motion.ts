import { Easing, interpolate, spring } from "remotion";

export const easeOut = Easing.bezier(0.16, 1, 0.3, 1);
export const easeIn = Easing.bezier(0.7, 0, 0.84, 0);
export const easeInOut = Easing.bezier(0.65, 0, 0.35, 1);

export const progress = (time: number, start: number, duration: number, easing = easeOut) =>
  interpolate(time, [start, start + duration], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing });

export const springAt = (seconds: number, damping = 16, stiffness = 120) =>
  seconds <= 0 ? 0 : spring({ frame: seconds * 60, fps: 60, config: { damping, stiffness, mass: 1 } });

export const lerp = (from: number, to: number, amount: number) => from + (to - from) * amount;
