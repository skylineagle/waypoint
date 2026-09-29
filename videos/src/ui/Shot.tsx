import { AbsoluteFill, interpolate } from "remotion";
import type { FC, ReactNode } from "react";
import type { SceneWindow } from "../cues";
import { easeIn, easeOut, progress } from "../motion";
import { useTime } from "../useTime";

export const ENTER_LEAD = 0.12;
export const EXIT_LEAD = 0.32;
const ENTER = 0.55;
const EXIT = 0.4;

export type ShotProps = { window: SceneWindow; enters?: boolean; exits?: boolean; children: ReactNode };

export const Shot: FC<ShotProps> = ({ window, enters = true, exits = true, children }) => {
  const time = useTime();
  const enterStart = window.start - ENTER_LEAD;
  const exitStart = window.end - EXIT_LEAD;
  if ((enters && time < enterStart) || (exits && time >= exitStart + EXIT)) return null;
  const inbound = enters ? progress(time, enterStart, ENTER, easeOut) : 1;
  const outbound = exits ? progress(time, exitStart, EXIT, easeIn) : 0;
  const scale = interpolate(inbound, [0, 1], [0.45, 1]) * interpolate(outbound, [0, 1], [1, 2.4]);
  const blur = (1 - inbound) * 18 + outbound * 22;
  const opacity = Math.min(interpolate(inbound, [0, 0.35], [0, 1], { extrapolateRight: "clamp" }), 1 - outbound);
  return (
    <AbsoluteFill style={{ transform: `scale(${scale})`, filter: blur > 0.05 ? `blur(${blur}px)` : undefined, opacity }}>{children}</AbsoluteFill>
  );
};
