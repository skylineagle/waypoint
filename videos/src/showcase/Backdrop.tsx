import { AbsoluteFill } from "remotion";
import type { FC } from "react";
import { colors } from "../theme";
import { useTime } from "../useTime";
import { Glow } from "./Glow";

export const Backdrop: FC = () => {
  const time = useTime();
  const drift = Math.sin(time / 2.2);
  const sway = Math.cos(time / 2.9);
  return (
    <AbsoluteFill style={{ backgroundColor: colors.night, overflow: "hidden" }}>
      <Glow x={260 + drift * 120} y={120 + sway * 60} size={1500} color="rgba(79, 70, 229, 0.55)" />
      <Glow x={1700 - drift * 100} y={980 + sway * 70} size={1400} color="rgba(6, 182, 212, 0.36)" />
      <Glow x={960 + sway * 160} y={560 + drift * 50} size={1100} color="rgba(139, 92, 246, 0.22)" />
      <AbsoluteFill
        style={{
          backgroundImage: "radial-gradient(rgba(255,255,255,0.28) 2px, transparent 2.5px)",
          backgroundSize: "26px 26px",
          opacity: 0.45,
          WebkitMaskImage: "radial-gradient(ellipse 60% 55% at 50% 30%, #000 10%, transparent 80%)",
        }}
      />
    </AbsoluteFill>
  );
};
