import { cuts } from "../cues";

const CRUISE = 90;
const BOOST = 1500;
const WIDTH = 0.22;
const pulses = [0, ...cuts];

const erf = (x: number) => {
  const sign = Math.sign(x);
  const a = Math.abs(x);
  const t = 1 / (1 + 0.3275911 * a);
  const y = 1 - ((((1.061405429 * t - 1.453152027) * t + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * Math.exp(-a * a);
  return sign * y;
};

export const warp = (time: number) => pulses.reduce((sum, cut) => sum + Math.exp(-(((time - cut) / WIDTH) ** 2)), 0);

export const speed = (time: number) => CRUISE + BOOST * warp(time);

export const distance = (time: number) =>
  CRUISE * time +
  BOOST * pulses.reduce((sum, cut) => sum + ((WIDTH * Math.sqrt(Math.PI)) / 2) * (erf((time - cut) / WIDTH) - erf(-cut / WIDTH)), 0);
