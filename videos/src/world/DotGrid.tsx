import type { FC } from "react";

export const DotGrid: FC = () => (
  <div
    style={{
      position: "absolute",
      inset: 0,
      backgroundImage: "radial-gradient(rgba(255,255,255,0.28) 2px, transparent 2.5px)",
      backgroundSize: "26px 26px",
      opacity: 0.5,
      WebkitMaskImage: "radial-gradient(ellipse 80% 40% at 50% 18%, #000 10%, transparent 80%)",
    }}
  />
);
