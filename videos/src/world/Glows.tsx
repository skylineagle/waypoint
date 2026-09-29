import type { FC } from "react";
import { useTime } from "../useTime";
import { warp } from "./travel";

type GlowProps = { x: number; y: number; size: number; color: string };

const Glow: FC<GlowProps> = ({ x, y, size, color }) => (
  <div
    style={{
      position: "absolute",
      left: x - size / 2,
      top: y - size / 2,
      width: size,
      height: size,
      borderRadius: "50%",
      background: `radial-gradient(closest-side, ${color}, transparent)`,
    }}
  />
);

export const Glows: FC = () => {
  const time = useTime();
  const drift = Math.sin(time / 1.4);
  const sway = Math.cos(time / 1.9);
  const flare = 1 + 0.35 * Math.min(1, warp(time));
  return (
    <div style={{ position: "absolute", inset: 0, filter: `brightness(${flare})` }}>
      <Glow x={120 + drift * 110} y={140 + sway * 70} size={1400} color="rgba(79, 70, 229, 0.6)" />
      <Glow x={980 - drift * 90} y={1560 + sway * 90} size={1300} color="rgba(6, 182, 212, 0.42)" />
      <Glow x={540 + sway * 140} y={930 + drift * 70} size={1050} color="rgba(139, 92, 246, 0.26)" />
    </div>
  );
};
