import type { CSSProperties, FC, ReactNode } from "react";

export type PlacedProps = {
  x?: number;
  y?: number;
  z?: number;
  rotateY?: number;
  rotateX?: number;
  scale?: number;
  opacity?: number;
  style?: CSSProperties;
  children: ReactNode;
};

export const Placed: FC<PlacedProps> = ({ x = 0, y = 0, z = 0, rotateY = 0, rotateX = 0, scale = 1, opacity = 1, style, children }) => (
  <div
    style={{
      position: "absolute",
      left: "50%",
      top: "50%",
      whiteSpace: "nowrap",
      transformStyle: "preserve-3d",
      opacity,
      transform: `translate(-50%, -50%) translate3d(${x}px, ${y}px, ${z}px) rotateY(${rotateY}deg) rotateX(${rotateX}deg) scale(${scale})`,
      ...style,
    }}
  >
    {children}
  </div>
);
