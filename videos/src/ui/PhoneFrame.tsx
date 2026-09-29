import type { FC, ReactNode } from "react";
import { phoneMetrics } from "./phoneGeometry";

export type PhoneFrameProps = { width: number; children: ReactNode };

export const PhoneFrame: FC<PhoneFrameProps> = ({ width, children }) => {
  const { bezel, screenWidth, screenHeight } = phoneMetrics(width);
  const radius = screenWidth * 0.118;
  return (
    <div
      style={{
        width,
        padding: bezel,
        borderRadius: radius + bezel,
        background: "linear-gradient(145deg, #444a58, #15171e 38%, #2c303a 70%, #4a4f5c)",
        boxShadow: "0 0 0 2px #555b69, 0 100px 160px rgba(0,0,0,0.6), 0 0 220px rgba(79,70,229,0.28)",
      }}
    >
      <div style={{ position: "relative", width: screenWidth, height: screenHeight, borderRadius: radius, overflow: "hidden", backgroundColor: "#000" }}>
        {children}
        <div
          style={{
            position: "absolute",
            inset: 0,
            borderRadius: radius,
            background: "linear-gradient(125deg, rgba(255,255,255,0.10), transparent 30%)",
            pointerEvents: "none",
          }}
        />
      </div>
    </div>
  );
};
