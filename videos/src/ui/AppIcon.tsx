import { Img, staticFile } from "remotion";
import type { FC } from "react";

export type AppIconProps = { size: number };

export const AppIcon: FC<AppIconProps> = ({ size }) => (
  <Img
    src={staticFile("app-icon.png")}
    style={{
      width: size,
      height: size,
      borderRadius: size * 0.225,
      boxShadow: "0 50px 120px rgba(0,0,0,0.55), 0 0 0 3px rgba(255,255,255,0.14), 0 0 260px rgba(79,70,229,0.65)",
    }}
  />
);
