import { AbsoluteFill, interpolate } from "remotion";
import type { FC, ReactNode } from "react";
import type { SceneWindow } from "../cues";
import { easeInOut } from "../motion";
import { useTime } from "../useTime";

export type StageProps = { window: SceneWindow; orbitFrom: number; orbitTo: number; tilt?: number; children: ReactNode };

export const Stage: FC<StageProps> = ({ window, orbitFrom, orbitTo, tilt = 3, children }) => {
  const time = useTime();
  const orbit = interpolate(time, [window.start - 0.2, window.end + 0.2], [orbitFrom, orbitTo], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: easeInOut,
  });
  return (
    <AbsoluteFill style={{ perspective: 2300, perspectiveOrigin: "50% 55%" }}>
      <AbsoluteFill style={{ transformStyle: "preserve-3d", transform: `rotateX(${tilt}deg) rotateY(${orbit}deg)` }}>{children}</AbsoluteFill>
    </AbsoluteFill>
  );
};
