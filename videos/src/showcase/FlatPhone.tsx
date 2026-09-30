import type { FC } from "react";
import { progress } from "../motion";
import { phoneMetrics } from "../ui/phoneGeometry";
import { ScreenImage } from "../ui/ScreenImage";
import { useTime } from "../useTime";

export type ScreenCue = { name: string; at: number };

export type FlatPhoneProps = { width: number; screens: ScreenCue[]; fade?: number };

export const FlatPhone: FC<FlatPhoneProps> = ({ width, screens, fade = 0.3 }) => {
  const time = useTime();
  const { bezel, screenWidth, screenHeight } = phoneMetrics(width);
  const radius = screenWidth * 0.118;
  return (
    <div
      style={{
        width,
        padding: bezel,
        borderRadius: radius + bezel,
        backgroundColor: "#0b0f1c",
        boxShadow: "0 0 0 2px #2a3042, 0 40px 90px rgba(0,0,0,0.5)",
      }}
    >
      <div style={{ position: "relative", width: screenWidth, height: screenHeight, borderRadius: radius, overflow: "hidden", backgroundColor: "#000" }}>
        {screens.map((screen, index) => (
          <div key={screen.name} style={{ position: "absolute", inset: 0, opacity: index === 0 ? 1 : progress(time, screen.at, fade) }}>
            <ScreenImage name={screen.name} />
          </div>
        ))}
      </div>
    </div>
  );
};
