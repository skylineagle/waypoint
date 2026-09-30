import type { FC } from "react";

export type GlowProps = { x: number; y: number; size: number; color: string };

export const Glow: FC<GlowProps> = ({ x, y, size, color }) => (
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
