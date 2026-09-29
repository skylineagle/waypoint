import { AbsoluteFill } from "remotion";
import type { FC } from "react";

export const DayBackdrop: FC = () => (
  <AbsoluteFill style={{ background: "linear-gradient(180deg, #f5f7ff 0%, #eef2ff 45%, #e0f2fe 100%)" }}>
    <div style={{ position: "absolute", left: -500, top: -500, width: 1400, height: 1400, borderRadius: "50%", background: "radial-gradient(closest-side, rgba(99,102,241,0.22), transparent)" }} />
    <div style={{ position: "absolute", left: 300, top: 1000, width: 1300, height: 1300, borderRadius: "50%", background: "radial-gradient(closest-side, rgba(6,182,212,0.22), transparent)" }} />
    <div
      style={{
        position: "absolute",
        inset: 0,
        backgroundImage: "radial-gradient(rgba(17,24,39,0.16) 2px, transparent 2.5px)",
        backgroundSize: "26px 26px",
        WebkitMaskImage: "radial-gradient(ellipse 80% 40% at 50% 18%, #000 10%, transparent 80%)",
      }}
    />
  </AbsoluteFill>
);
